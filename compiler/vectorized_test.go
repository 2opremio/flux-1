package compiler_test

import (
	"context"
	"fmt"
	"testing"

	arrow "github.com/apache/arrow/go/v7/arrow/memory"
	"github.com/google/go-cmp/cmp"
	"github.com/influxdata/flux/compiler"
	"github.com/influxdata/flux/execute/executetest"
	fluxfeature "github.com/influxdata/flux/internal/feature"
	"github.com/influxdata/flux/internal/pkg/feature"
	"github.com/influxdata/flux/memory"
	"github.com/influxdata/flux/runtime"
	"github.com/influxdata/flux/semantic"
	"github.com/influxdata/flux/values"
)

func vectorizedObjectFromMap(mp map[string]interface{}, mem memory.Allocator) values.Object {
	obj := make(map[string]values.Value)
	for k, v := range mp {
		switch s := v.(type) {
		case []interface{}:
			obj[k] = values.NewVectorFromElements(mem, s...)
		case map[string]interface{}:
			obj[k] = vectorizedObjectFromMap(v.(map[string]interface{}), mem)
		default:
			panic("bad input to vectorizedObjectFromMap")
		}
	}
	return values.NewObjectWithValues(obj)
}

// Check that:
//     1. Vectorized inputs yield vectorized outputs when compiled and evaluated
//     2. The number of bytes allocated is 0 once evaluation is complete
//        and values are released
//     3. Only certain function expressions are vectorized when invoking the
//        analyzer from go code. The criteria for supported expressions may
//        change in the future, but right now we only support trivial identity
//        functions (i.e., those in the form of `(r) => ({a: r.a})`, or something
//        similar)
func TestVectorizedFns(t *testing.T) {
	type TestCase struct {
		name         string
		fn           string
		vectorizable bool
		inType       semantic.MonoType
		input        map[string]interface{}
		want         map[string]interface{}
		skipComp     bool
		flagger      executetest.TestFlagger
	}

	testCases := []TestCase{
		{
			name:         "field access",
			fn:           `(r) => ({c: r.a, d: r.b})`,
			vectorizable: true,
			inType: semantic.NewObjectType([]semantic.PropertyType{
				{Key: []byte("r"), Value: semantic.NewObjectType([]semantic.PropertyType{
					{Key: []byte("a"), Value: semantic.NewVectorType(semantic.BasicInt)},
					{Key: []byte("b"), Value: semantic.NewVectorType(semantic.BasicInt)},
				})},
			}),
			input: map[string]interface{}{
				"r": map[string]interface{}{
					"a": []interface{}{int64(1)},
					"b": []interface{}{int64(2)},
				},
			},
			want: map[string]interface{}{
				"c": []interface{}{int64(1)},
				"d": []interface{}{int64(2)},
			},
		},
		{
			name:         "extend record",
			fn:           `(r) => ({r with b: r.a})`,
			vectorizable: true,
			inType: semantic.NewObjectType([]semantic.PropertyType{
				{Key: []byte("r"), Value: semantic.NewObjectType([]semantic.PropertyType{
					{Key: []byte("a"), Value: semantic.NewVectorType(semantic.BasicFloat)},
				})},
			}),
			input: map[string]interface{}{
				"r": map[string]interface{}{
					"a": []interface{}{1.2},
				},
			},
			want: map[string]interface{}{
				"a": []interface{}{1.2},
				"b": []interface{}{1.2},
			},
		},
		{
			name:         "no binary expressions without feature flag",
			fn:           `(r) => ({c: r.a + r.b})`,
			vectorizable: false,
			skipComp:     true,
		},
		{
			name:         "no literals",
			fn:           `(r) => ({r with c: "count"})`,
			vectorizable: false,
			skipComp:     true,
		},
	}

	operatorTests := []struct {
		inType semantic.MonoType
		input  map[string]interface{}
		want   map[string]interface{}
	}{
		{
			inType: semantic.BasicInt,
			input: map[string]interface{}{
				"r": map[string]interface{}{
					"a": []interface{}{int64(1)},
					"b": []interface{}{int64(2)},
				},
			},
			want: map[string]interface{}{
				"c": []interface{}{int64(3)},
			},
		},
		{
			inType: semantic.BasicUint,
			input: map[string]interface{}{
				"r": map[string]interface{}{
					"a": []interface{}{uint64(1)},
					"b": []interface{}{uint64(2)},
				},
			},
			want: map[string]interface{}{
				"c": []interface{}{uint64(3)},
			},
		},
		{
			inType: semantic.BasicFloat,
			input: map[string]interface{}{
				"r": map[string]interface{}{
					"a": []interface{}{1.0},
					"b": []interface{}{2.0},
				},
			},
			want: map[string]interface{}{
				"c": []interface{}{3.0},
			},
		},
		{
			inType: semantic.BasicString,
			input: map[string]interface{}{
				"r": map[string]interface{}{
					"a": []interface{}{"a"},
					"b": []interface{}{"b"},
				},
			},
			want: map[string]interface{}{
				"c": []interface{}{"ab"},
			},
		},
	}

	for _, test := range operatorTests {
		testCases = append(testCases, TestCase{
			name:         fmt.Sprintf("addition expression %s", test.inType.String()),
			fn:           `(r) => ({c: r.a + r.b})`,
			vectorizable: true,
			inType: semantic.NewObjectType([]semantic.PropertyType{
				{Key: []byte("r"), Value: semantic.NewObjectType([]semantic.PropertyType{
					{Key: []byte("a"), Value: semantic.NewVectorType(test.inType)},
					{Key: []byte("b"), Value: semantic.NewVectorType(test.inType)},
				})},
			}),
			input: test.input,
			want:  test.want,

			flagger: executetest.TestFlagger{
				fluxfeature.VectorizeAddition().Key(): true,
			},
		})
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			checked := arrow.NewCheckedAllocator(memory.DefaultAllocator)
			mem := &memory.GcAllocator{ResourceAllocator: &memory.ResourceAllocator{Allocator: checked}}

			ctx := context.Background()
			ctx = feature.Inject(
				ctx,
				tc.flagger,
			)
			ctx = compiler.RuntimeDependencies{Allocator: mem}.Inject(ctx)

			pkg, err := runtime.AnalyzeSource(ctx, tc.fn)
			if err != nil {
				t.Fatalf("unexpected error: %s", err)
			}

			stmt := pkg.Files[0].Body[0].(*semantic.ExpressionStatement)
			fn := stmt.Expression.(*semantic.FunctionExpression)

			if tc.vectorizable {
				if fn.Vectorized == nil {
					t.Fatal("Expected to find vectorized node, but found none")
				}
			} else {
				if fn.Vectorized != nil {
					t.Fatal("Vectorized node is populated when it should be nil")
				}
			}

			if tc.skipComp {
				return
			}

			f, err := compiler.Compile(nil, fn, tc.inType)
			if err != nil {
				t.Fatalf("unexpected error: %s", err)
			}
			input := vectorizedObjectFromMap(tc.input, mem)
			got, err := f.Eval(ctx, input)
			if err != nil {
				t.Fatalf("unexpected error: %s", err)
			}

			want := vectorizedObjectFromMap(tc.want, &memory.GcAllocator{ResourceAllocator: &memory.ResourceAllocator{}})
			if !cmp.Equal(want, got, CmpOptions...) {
				t.Errorf("unexpected value -want/+got\n%s", cmp.Diff(want, got, CmpOptions...))
			}

			got.Release()
			input.Release()

			mem.GC()
			checked.AssertSize(t, 0)
		})
	}
}
