// Generated by tmpl
// https://github.com/benbjohnson/tmpl
//
// DO NOT EDIT!
// Source: aggregate_window.gen.go.tmpl

package universe

import (
	"github.com/apache/arrow/go/v7/arrow/memory"
	"github.com/influxdata/flux"
	"github.com/influxdata/flux/array"
)

type aggregateWindowSumInt struct {
	aggregateWindowBase
	vs *array.Int
}

func (a *aggregateWindowSumInt) Aggregate(ts *array.Int, vs array.Array, start, stop *array.Int, mem memory.Allocator) {
	b := array.NewIntBuilder(mem)
	b.Resize(stop.Len())

	values := vs.(*array.Int)
	aggregateWindows(ts, start, stop, func(i, j int) {
		var sum int64
		for ; i < j; i++ {
			sum += values.Value(i)
		}
		b.Append(sum)
	})
	result := b.NewIntArray()
	a.mergeWindows(start, stop, mem, func(ts, prev, next *array.Int) {
		if a.vs == nil {
			a.vs = result
			return
		}
		defer result.Release()

		merged := array.NewIntBuilder(mem)
		merged.Resize(ts.Len())
		mergeWindowValues(ts, prev, next, func(i, j int) {
			if i >= 0 && j >= 0 {
				merged.Append(a.vs.Value(i) + result.Value(j))
			} else if i >= 0 {
				merged.Append(a.vs.Value(i))
			} else {
				merged.Append(result.Value(j))
			}
		})
		a.vs.Release()
		a.vs = merged.NewIntArray()
	})
}

func (a *aggregateWindowSumInt) Compute(mem memory.Allocator) (*array.Int, flux.ColType, array.Array) {
	a.createEmptyWindows(mem, func(n int) (append func(i int), done func()) {
		b := array.NewIntBuilder(mem)
		b.Resize(n)

		append = func(i int) {
			if i < 0 {
				b.AppendNull()
			} else {
				b.Append(a.vs.Value(i))
			}
		}

		done = func() {
			a.vs.Release()
			a.vs = b.NewIntArray()
		}
		return append, done
	})
	return a.ts, flux.TInt, a.vs
}

type aggregateWindowMeanInt struct {
	aggregateWindowBase
	counts *array.Int
	sums   *array.Int
}

func (a *aggregateWindowMeanInt) Aggregate(ts *array.Int, vs array.Array, start, stop *array.Int, mem memory.Allocator) {
	countsB := array.NewIntBuilder(mem)
	countsB.Resize(stop.Len())

	sumsB := array.NewIntBuilder(mem)
	sumsB.Resize(stop.Len())

	values := vs.(*array.Int)
	aggregateWindows(ts, start, stop, func(i, j int) {
		countsB.Append(int64(j - i))
		var sum int64
		for ; i < j; i++ {
			sum += values.Value(i)
		}
		sumsB.Append(sum)
	})

	counts, sums := countsB.NewIntArray(), sumsB.NewIntArray()
	a.mergeWindows(start, stop, mem, func(ts, prev, next *array.Int) {
		if a.sums == nil {
			a.counts, a.sums = counts, sums
			return
		}
		defer counts.Release()
		defer sums.Release()

		mergedCounts := array.NewIntBuilder(mem)
		mergedCounts.Resize(ts.Len())
		mergedSums := array.NewIntBuilder(mem)
		mergedSums.Resize(ts.Len())
		mergeWindowValues(ts, prev, next, func(i, j int) {
			if i >= 0 && j >= 0 {
				mergedCounts.Append(a.counts.Value(i) + counts.Value(j))
				mergedSums.Append(a.sums.Value(i) + sums.Value(j))
			} else if i >= 0 {
				mergedCounts.Append(a.counts.Value(i))
				mergedSums.Append(a.sums.Value(i))
			} else {
				mergedCounts.Append(counts.Value(j))
				mergedSums.Append(sums.Value(j))
			}
		})
		a.counts.Release()
		a.sums.Release()
		a.counts, a.sums = mergedCounts.NewIntArray(), mergedSums.NewIntArray()
	})
}

func (a *aggregateWindowMeanInt) Compute(mem memory.Allocator) (*array.Int, flux.ColType, array.Array) {
	defer a.counts.Release()
	defer a.sums.Release()

	b := array.NewFloatBuilder(mem)
	b.Resize(a.ts.Len())
	for i, n := 0, a.sums.Len(); i < n; i++ {
		v := float64(a.sums.Value(i)) / float64(a.counts.Value(i))
		b.Append(v)
	}
	vs := b.NewFloatArray()

	a.createEmptyWindows(mem, func(n int) (append func(i int), done func()) {
		b := array.NewFloatBuilder(mem)
		b.Resize(n)

		append = func(i int) {
			if i < 0 {
				b.AppendNull()
			} else {
				b.Append(vs.Value(i))
			}
		}

		done = func() {
			vs.Release()
			vs = b.NewFloatArray()
		}
		return append, done
	})
	return a.ts, flux.TFloat, vs
}

type aggregateWindowSumUint struct {
	aggregateWindowBase
	vs *array.Uint
}

func (a *aggregateWindowSumUint) Aggregate(ts *array.Int, vs array.Array, start, stop *array.Int, mem memory.Allocator) {
	b := array.NewUintBuilder(mem)
	b.Resize(stop.Len())

	values := vs.(*array.Uint)
	aggregateWindows(ts, start, stop, func(i, j int) {
		var sum uint64
		for ; i < j; i++ {
			sum += values.Value(i)
		}
		b.Append(sum)
	})
	result := b.NewUintArray()
	a.mergeWindows(start, stop, mem, func(ts, prev, next *array.Int) {
		if a.vs == nil {
			a.vs = result
			return
		}
		defer result.Release()

		merged := array.NewUintBuilder(mem)
		merged.Resize(ts.Len())
		mergeWindowValues(ts, prev, next, func(i, j int) {
			if i >= 0 && j >= 0 {
				merged.Append(a.vs.Value(i) + result.Value(j))
			} else if i >= 0 {
				merged.Append(a.vs.Value(i))
			} else {
				merged.Append(result.Value(j))
			}
		})
		a.vs.Release()
		a.vs = merged.NewUintArray()
	})
}

func (a *aggregateWindowSumUint) Compute(mem memory.Allocator) (*array.Int, flux.ColType, array.Array) {
	a.createEmptyWindows(mem, func(n int) (append func(i int), done func()) {
		b := array.NewUintBuilder(mem)
		b.Resize(n)

		append = func(i int) {
			if i < 0 {
				b.AppendNull()
			} else {
				b.Append(a.vs.Value(i))
			}
		}

		done = func() {
			a.vs.Release()
			a.vs = b.NewUintArray()
		}
		return append, done
	})
	return a.ts, flux.TUInt, a.vs
}

type aggregateWindowMeanUint struct {
	aggregateWindowBase
	counts *array.Int
	sums   *array.Uint
}

func (a *aggregateWindowMeanUint) Aggregate(ts *array.Int, vs array.Array, start, stop *array.Int, mem memory.Allocator) {
	countsB := array.NewIntBuilder(mem)
	countsB.Resize(stop.Len())

	sumsB := array.NewUintBuilder(mem)
	sumsB.Resize(stop.Len())

	values := vs.(*array.Uint)
	aggregateWindows(ts, start, stop, func(i, j int) {
		countsB.Append(int64(j - i))
		var sum uint64
		for ; i < j; i++ {
			sum += values.Value(i)
		}
		sumsB.Append(sum)
	})

	counts, sums := countsB.NewIntArray(), sumsB.NewUintArray()
	a.mergeWindows(start, stop, mem, func(ts, prev, next *array.Int) {
		if a.sums == nil {
			a.counts, a.sums = counts, sums
			return
		}
		defer counts.Release()
		defer sums.Release()

		mergedCounts := array.NewIntBuilder(mem)
		mergedCounts.Resize(ts.Len())
		mergedSums := array.NewUintBuilder(mem)
		mergedSums.Resize(ts.Len())
		mergeWindowValues(ts, prev, next, func(i, j int) {
			if i >= 0 && j >= 0 {
				mergedCounts.Append(a.counts.Value(i) + counts.Value(j))
				mergedSums.Append(a.sums.Value(i) + sums.Value(j))
			} else if i >= 0 {
				mergedCounts.Append(a.counts.Value(i))
				mergedSums.Append(a.sums.Value(i))
			} else {
				mergedCounts.Append(counts.Value(j))
				mergedSums.Append(sums.Value(j))
			}
		})
		a.counts.Release()
		a.sums.Release()
		a.counts, a.sums = mergedCounts.NewIntArray(), mergedSums.NewUintArray()
	})
}

func (a *aggregateWindowMeanUint) Compute(mem memory.Allocator) (*array.Int, flux.ColType, array.Array) {
	defer a.counts.Release()
	defer a.sums.Release()

	b := array.NewFloatBuilder(mem)
	b.Resize(a.ts.Len())
	for i, n := 0, a.sums.Len(); i < n; i++ {
		v := float64(a.sums.Value(i)) / float64(a.counts.Value(i))
		b.Append(v)
	}
	vs := b.NewFloatArray()

	a.createEmptyWindows(mem, func(n int) (append func(i int), done func()) {
		b := array.NewFloatBuilder(mem)
		b.Resize(n)

		append = func(i int) {
			if i < 0 {
				b.AppendNull()
			} else {
				b.Append(vs.Value(i))
			}
		}

		done = func() {
			vs.Release()
			vs = b.NewFloatArray()
		}
		return append, done
	})
	return a.ts, flux.TFloat, vs
}

type aggregateWindowSumFloat struct {
	aggregateWindowBase
	vs *array.Float
}

func (a *aggregateWindowSumFloat) Aggregate(ts *array.Int, vs array.Array, start, stop *array.Int, mem memory.Allocator) {
	b := array.NewFloatBuilder(mem)
	b.Resize(stop.Len())

	values := vs.(*array.Float)
	aggregateWindows(ts, start, stop, func(i, j int) {
		var sum float64
		for ; i < j; i++ {
			sum += values.Value(i)
		}
		b.Append(sum)
	})
	result := b.NewFloatArray()
	a.mergeWindows(start, stop, mem, func(ts, prev, next *array.Int) {
		if a.vs == nil {
			a.vs = result
			return
		}
		defer result.Release()

		merged := array.NewFloatBuilder(mem)
		merged.Resize(ts.Len())
		mergeWindowValues(ts, prev, next, func(i, j int) {
			if i >= 0 && j >= 0 {
				merged.Append(a.vs.Value(i) + result.Value(j))
			} else if i >= 0 {
				merged.Append(a.vs.Value(i))
			} else {
				merged.Append(result.Value(j))
			}
		})
		a.vs.Release()
		a.vs = merged.NewFloatArray()
	})
}

func (a *aggregateWindowSumFloat) Compute(mem memory.Allocator) (*array.Int, flux.ColType, array.Array) {
	a.createEmptyWindows(mem, func(n int) (append func(i int), done func()) {
		b := array.NewFloatBuilder(mem)
		b.Resize(n)

		append = func(i int) {
			if i < 0 {
				b.AppendNull()
			} else {
				b.Append(a.vs.Value(i))
			}
		}

		done = func() {
			a.vs.Release()
			a.vs = b.NewFloatArray()
		}
		return append, done
	})
	return a.ts, flux.TFloat, a.vs
}

type aggregateWindowMeanFloat struct {
	aggregateWindowBase
	counts *array.Int
	sums   *array.Float
}

func (a *aggregateWindowMeanFloat) Aggregate(ts *array.Int, vs array.Array, start, stop *array.Int, mem memory.Allocator) {
	countsB := array.NewIntBuilder(mem)
	countsB.Resize(stop.Len())

	sumsB := array.NewFloatBuilder(mem)
	sumsB.Resize(stop.Len())

	values := vs.(*array.Float)
	aggregateWindows(ts, start, stop, func(i, j int) {
		countsB.Append(int64(j - i))
		var sum float64
		for ; i < j; i++ {
			sum += values.Value(i)
		}
		sumsB.Append(sum)
	})

	counts, sums := countsB.NewIntArray(), sumsB.NewFloatArray()
	a.mergeWindows(start, stop, mem, func(ts, prev, next *array.Int) {
		if a.sums == nil {
			a.counts, a.sums = counts, sums
			return
		}
		defer counts.Release()
		defer sums.Release()

		mergedCounts := array.NewIntBuilder(mem)
		mergedCounts.Resize(ts.Len())
		mergedSums := array.NewFloatBuilder(mem)
		mergedSums.Resize(ts.Len())
		mergeWindowValues(ts, prev, next, func(i, j int) {
			if i >= 0 && j >= 0 {
				mergedCounts.Append(a.counts.Value(i) + counts.Value(j))
				mergedSums.Append(a.sums.Value(i) + sums.Value(j))
			} else if i >= 0 {
				mergedCounts.Append(a.counts.Value(i))
				mergedSums.Append(a.sums.Value(i))
			} else {
				mergedCounts.Append(counts.Value(j))
				mergedSums.Append(sums.Value(j))
			}
		})
		a.counts.Release()
		a.sums.Release()
		a.counts, a.sums = mergedCounts.NewIntArray(), mergedSums.NewFloatArray()
	})
}

func (a *aggregateWindowMeanFloat) Compute(mem memory.Allocator) (*array.Int, flux.ColType, array.Array) {
	defer a.counts.Release()
	defer a.sums.Release()

	b := array.NewFloatBuilder(mem)
	b.Resize(a.ts.Len())
	for i, n := 0, a.sums.Len(); i < n; i++ {
		v := float64(a.sums.Value(i)) / float64(a.counts.Value(i))
		b.Append(v)
	}
	vs := b.NewFloatArray()

	a.createEmptyWindows(mem, func(n int) (append func(i int), done func()) {
		b := array.NewFloatBuilder(mem)
		b.Resize(n)

		append = func(i int) {
			if i < 0 {
				b.AppendNull()
			} else {
				b.Append(vs.Value(i))
			}
		}

		done = func() {
			vs.Release()
			vs = b.NewFloatArray()
		}
		return append, done
	})
	return a.ts, flux.TFloat, vs
}
