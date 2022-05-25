package anomalydetection_test


import "testing"
import "csv"
import "contrib/anaisdg/anomalydetection"

inData =
    "
#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,0,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,-0.8799998313250104,5,example_data
,,0,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-0.7414635537644934,5,example_data
,,0,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-0.8427951268771462,5,example_data
,,0,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.9120780818517797,5,example_data
,,0,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.16395277173516498,5,example_data
,,0,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,-0.4010719701430263,5,example_data
,,0,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,0.2920916295427288,5,example_data
,,0,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,-0.103320046239067,5,example_data

#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,1,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,-0.46750829880067657,8,example_data
,,1,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-0.9252219990376301,8,example_data
,,1,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-0.7308008938746421,8,example_data
,,1,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.8613936571202077,8,example_data
,,1,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.8850614164738824,8,example_data
,,1,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,0.17591540820792284,8,example_data
,,1,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,0.5606414332097589,8,example_data
,,1,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,-0.22589224003150699,8,example_data

#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,2,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,-1.106927231713163,7,example_data
,,2,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-0.9005225533887486,7,example_data
,,2,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-0.8840689132241709,7,example_data
,,2,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.4625836580666143,7,example_data
,,2,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.5046197479521373,7,example_data
,,2,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,0.13323536367228045,7,example_data
,,2,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,0.012094891300124325,7,example_data
,,2,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,-0.35606368250762627,7,example_data

#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,3,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,-0.8722333390014486,9,example_data
,,3,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-0.8307017247064687,9,example_data
,,3,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-0.2695212351379527,9,example_data
,,3,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.138342810421192,9,example_data
,,3,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.44846303859314673,9,example_data
,,3,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,-0.23802513139695342,9,example_data
,,3,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,-0.547323729045929,9,example_data
,,3,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,0.1049103155656222,9,example_data

#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,4,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,-1.1331836912886002,outlier,example_data
,,4,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-1.1381229352104967,outlier,example_data
,,4,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-0.6015568799565542,outlier,example_data
,,4,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.38128104311275723,outlier,example_data
,,4,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.24666143594348838,outlier,example_data
,,4,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,-0.06141767736662415,outlier,example_data
,,4,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,0.48001306951954864,outlier,example_data
,,4,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,0.06131635592397959,outlier,example_data

#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,5,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,-1.15746839236107,1,example_data
,,5,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-0.7211366390432268,1,example_data
,,5,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-0.6053199130926501,1,example_data
,,5,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.4460497863806818,1,example_data
,,5,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.35243153664987104,1,example_data
,,5,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,-0.4753669782808946,1,example_data
,,5,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,-0.125963078075766,1,example_data
,,5,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,-0.21035886349154215,1,example_data

#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,6,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,-0.7478119559642759,0,example_data
,,6,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-0.5820836753251758,0,example_data
,,6,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-0.7112692206292269,0,example_data
,,6,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.37387018611213807,0,example_data
,,6,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.515240632322408,0,example_data
,,6,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,0.453279407339119,0,example_data
,,6,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,-0.178026589231857,0,example_data
,,6,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,-0.03050916415842255,0,example_data

#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,7,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,0.02092968071081236,2,example_data
,,7,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-0.9181898213946273,2,example_data
,,7,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-1.0276689397273886,2,example_data
,,7,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.4335252723648398,2,example_data
,,7,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.6657280782824372,2,example_data
,,7,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,-0.5020036989110646,2,example_data
,,7,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,0.3562677060973325,2,example_data
,,7,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,-0.07851220704149846,2,example_data

#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,8,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,-0.5496770493044243,3,example_data
,,8,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-1.1979379868010953,3,example_data
,,8,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-0.8717358300017246,3,example_data
,,8,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.01133246535417265,3,example_data
,,8,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.5004628814040356,3,example_data
,,8,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,-0.10266712000425773,3,example_data
,,8,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,-0.04114387816286625,3,example_data
,,8,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,0.30058314197856295,3,example_data

#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,9,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,-0.67940601664335,4,example_data
,,9,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-1.1693292800132882,4,example_data
,,9,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-1.2332993091695257,4,example_data
,,9,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.1942613219339802,4,example_data
,,9,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.049963712935835625,4,example_data
,,9,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,0.2955364649394989,4,example_data
,,9,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,0.07039333272186515,4,example_data
,,9,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,0.07065642028313848,4,example_data

#group,false,false,true,true,false,false,true,true
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,double,string,string
#default,_result,,,,,,,
,result,table,_start,_stop,_time,_value,_field,_measurement
,,10,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T02:41:55.662650624Z,-0.49724931202381617,6,example_data
,,10,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-27T14:21:41.2048192Z,-1.0268796673953848,6,example_data
,,10,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T02:01:26.746988032Z,-0.576937574698975,6,example_data
,,10,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-28T13:41:12.289156608Z,-0.07349365327119334,6,example_data
,,10,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T01:20:57.831325184Z,-0.7820992176221472,6,example_data
,,10,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-29T13:00:43.373494016Z,0.5868445076910701,6,example_data
,,10,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T00:40:28.915662592Z,0.34646602596247655,6,example_data
,,10,2020-04-27T00:00:00Z,2020-05-01T00:00:00Z,2020-04-30T12:20:14.457831424Z,0.21777998866664877,6,example_data
"

testcase mad {
        got =
            csv.from(csv: inData)
                |> range(start: 2020-04-27T00:00:00Z, stop: 2020-05-01T00:00:00Z)
                |> anomalydetection.mad(threshold: 3.0)

        want =
            csv.from(
                csv:
                    "
#group,false,false,false,false,false,true,false,false,false,false
#datatype,string,long,double,string,string,dateTime:RFC3339,double,double,double,string
#default,_result,,,,,,,,,
,result,table,MAD,_field,_measurement,_time,_value,_value_diff,_value_diff_med,level
,,0,0.3714841759061255,0,example_data,2020-04-27T02:41:55.662650624Z,0,0,0.2505626439404597,normal
,,0,0.3714841759061255,1,example_data,2020-04-27T02:41:55.662650624Z,1.6349461753530161,0.40965643639679417,0.2505626439404597,normal
,,0,0.3714841759061255,2,example_data,2020-04-27T02:41:55.662650624Z,3.068061641534089,0.7687416366750882,0.2505626439404597,anomaly
,,0,0.3714841759061255,3,example_data,2020-04-27T02:41:55.662650624Z,0.7907599614367641,0.19813490665985156,0.2505626439404597,normal
,,0,0.3714841759061255,4,example_data,2020-04-27T02:41:55.662650624Z,0.2730093291048642,0.06840593932092587,0.2505626439404597,normal
,,0,0.3714841759061255,5,example_data,2020-04-27T02:41:55.662650624Z,0.5275641782904631,0.1321878753607345,0.2505626439404597,normal
,,0,0.3714841759061255,6,example_data,2020-04-27T02:41:55.662650624Z,1,0.2505626439404597,0.2505626439404597,normal
,,0,0.3714841759061255,7,example_data,2020-04-27T02:41:55.662650624Z,1.4332354979229167,0.35911527574888724,0.2505626439404597,normal
,,0,0.3714841759061255,8,example_data,2020-04-27T02:41:55.662650624Z,1.1186969164893026,0.2803036571635993,0.2505626439404597,normal
,,0,0.3714841759061255,9,example_data,2020-04-27T02:41:55.662650624Z,0.4965679683150956,0.12442138303717276,0.2505626439404597,normal
,,0,0.3714841759061255,outlier,example_data,2020-04-27T02:41:55.662650624Z,1.5380254983895318,0.38537173532432434,0.2505626439404597,normal
,,1,0.2620143643884366,0,example_data,2020-04-27T14:21:41.2048192Z,1.9018460049916277,0.33610614606945155,0.176726267630134,normal
,,1,0.2620143643884366,1,example_data,2020-04-27T14:21:41.2048192Z,1.1150192045237342,0.19705318235140057,0.176726267630134,normal
,,1,0.2620143643884366,2,example_data,2020-04-27T14:21:41.2048192Z,0,0,0.176726267630134,normal
,,1,0.2620143643884366,3,example_data,2020-04-27T14:21:41.2048192Z,1.5829461525886233,0.27974816540646796,0.176726267630134,normal
,,1,0.2620143643884366,4,example_data,2020-04-27T14:21:41.2048192Z,1.4210646894001313,0.2511394586186608,0.176726267630134,normal
,,1,0.2620143643884366,5,example_data,2020-04-27T14:21:41.2048192Z,1,0.176726267630134,0.176726267630134,normal
,,1,0.2620143643884366,6,example_data,2020-04-27T14:21:41.2048192Z,0.6150180584825781,0.10868984600075748,0.176726267630134,normal
,,1,0.2620143643884366,7,example_data,2020-04-27T14:21:41.2048192Z,0.09996967764211535,0.0176672680058787,0.176726267630134,normal
,,1,0.2620143643884366,8,example_data,2020-04-27T14:21:41.2048192Z,0.03979135494288976,0.0070321776430027905,0.176726267630134,normal
,,1,0.2620143643884366,9,example_data,2020-04-27T14:21:41.2048192Z,0.4950486300726967,0.0874880966881586,0.176726267630134,normal
,,1,0.2620143643884366,outlier,example_data,2020-04-27T14:21:41.2048192Z,1.2444845736014856,0.21993311381586933,0.176726267630134,normal
,,2,0.20895013630201253,0,example_data,2020-04-28T02:01:26.746988032Z,0.1385864554392904,0.01953167324541516,0.14093493612708252,normal
,,2,0.20895013630201253,1,example_data,2020-04-28T02:01:26.746988032Z,0.8903468808390026,0.125480980781992,0.14093493612708252,normal
,,2,0.20895013630201253,2,example_data,2020-04-28T02:01:26.746988032Z,2.1064191321948553,0.2968680458527465,0.14093493612708252,normal
,,2,0.20895013630201253,3,example_data,2020-04-28T02:01:26.746988032Z,1,0.14093493612708252,0.14093493612708252,normal
,,2,0.20895013630201253,4,example_data,2020-04-28T02:01:26.746988032Z,3.5654638168762887,0.5024984152948836,0.14093493612708252,anomaly
,,2,0.20895013630201253,5,example_data,2020-04-28T02:01:26.746988032Z,0.7946520293699053,0.1119942330025041,0.14093493612708252,normal
,,2,0.20895013630201253,6,example_data,2020-04-28T02:01:26.746988032Z,1.0917329897317078,0.1538633191756671,0.14093493612708252,normal
,,2,0.20895013630201253,7,example_data,2020-04-28T02:01:26.746988032Z,1.0875090560322491,0.15326801934952883,0.14093493612708252,normal
,,2,0.20895013630201253,8,example_data,2020-04-28T02:01:26.746988032Z,0,0,0.14093493612708252,normal
,,2,0.20895013630201253,9,example_data,2020-04-28T02:01:26.746988032Z,3.2729972525814937,0.4612796587366894,0.14093493612708252,anomaly
,,2,0.20895013630201253,outlier,example_data,2020-04-28T02:01:26.746988032Z,0.9170473799452198,0.12924401391808793,0.14093493612708252,normal
,,3,0.2772754386196548,0,example_data,2020-04-28T13:41:12.289156608Z,0.03962607234097485,0.007410857000619164,0.18701972117877702,normal
,,3,0.2772754386196548,1,example_data,2020-04-28T13:41:12.289156608Z,0.3463203926285959,0.06476874326792459,0.18701972117877702,normal
,,3,0.2772754386196548,2,example_data,2020-04-28T13:41:12.289156608Z,0.27935144445082843,0.05224422925208255,0.18701972117877702,normal
,,3,0.2772754386196548,3,example_data,2020-04-28T13:41:12.289156608Z,1.9781260255700044,0.3699485777585846,0.18701972117877702,normal
,,3,0.2772754386196548,4,example_data,2020-04-28T13:41:12.289156608Z,1,0.18701972117877702,0.18701972117877702,normal
,,3,0.2772754386196548,5,example_data,2020-04-28T13:41:12.289156608Z,2.8381875205108438,0.5307970387390225,0.18701972117877702,normal
,,3,0.2772754386196548,6,example_data,2020-04-28T13:41:12.289156608Z,1.6457483087964928,0.3077873898415639,0.18701972117877702,normal
,,3,0.2772754386196548,7,example_data,2020-04-28T13:41:12.289156608Z,0.43472749526846827,0.08130261495385704,0.18701972117877702,normal
,,3,0.2772754386196548,8,example_data,2020-04-28T13:41:12.289156608Z,2.567176397127115,0.4801126140074504,0.18701972117877702,normal
,,3,0.2772754386196548,9,example_data,2020-04-28T13:41:12.289156608Z,1.2989979407537147,0.24293823269156523,0.18701972117877702,normal
,,3,0.2772754386196548,outlier,example_data,2020-04-28T13:41:12.289156608Z,0,0,0.18701972117877702,normal
,,4,0.24502218089191816,0,example_data,2020-04-29T01:20:57.831325184Z,0.0894184087000819,0.014777750918372412,0.16526519687840158,normal
,,4,0.24502218089191816,1,example_data,2020-04-29T01:20:57.831325184Z,0.8957200157700639,0.14803134475416457,0.16526519687840158,normal
,,4,0.24502218089191816,2,example_data,2020-04-29T01:20:57.831325184Z,1,0.16526519687840158,0.16526519687840158,normal
,,4,0.24502218089191816,3,example_data,2020-04-29T01:20:57.831325184Z,0,0,0.16526519687840158,normal
,,4,0.24502218089191816,4,example_data,2020-04-29T01:20:57.831325184Z,2.7259167506372632,0.4504991684682,0.16526519687840158,normal
,,4,0.24502218089191816,5,example_data,2020-04-29T01:20:57.831325184Z,2.03618254795937,0.3365101096688706,0.16526519687840158,normal
,,4,0.24502218089191816,6,example_data,2020-04-29T01:20:57.831325184Z,1.704147887987168,0.28163633621811157,0.16526519687840158,normal
,,4,0.24502218089191816,7,example_data,2020-04-29T01:20:57.831325184Z,0.02515270381555401,0.0041568665481016565,0.16526519687840158,normal
,,4,0.24502218089191816,8,example_data,2020-04-29T01:20:57.831325184Z,2.3271598759708962,0.38459853506984676,0.16526519687840158,normal
,,4,0.24502218089191816,9,example_data,2020-04-29T01:20:57.831325184Z,0.31464484835938683,0.051999842810888874,0.16526519687840158,normal
,,4,0.24502218089191816,outlier,example_data,2020-04-29T01:20:57.831325184Z,1.5357222830605324,0.2538014454605472,0.16526519687840158,normal
,,5,0.5035714544702937,0,example_data,2020-04-29T13:00:43.373494016Z,1.515355747452818,0.5146970847057432,0.33965429277640213,normal
,,5,0.5035714544702937,1,example_data,2020-04-29T13:00:43.373494016Z,1.218737138666984,0.4139493009142704,0.33965429277640213,normal
,,5,0.5035714544702937,2,example_data,2020-04-29T13:00:43.373494016Z,1.2971601740787733,0.4405860215444404,0.33965429277640213,normal
,,5,0.5035714544702937,3,example_data,2020-04-29T13:00:43.373494016Z,0.12144537406093822,0.04124944263763358,0.33965429277640213,normal
,,5,0.5035714544702937,4,example_data,2020-04-29T13:00:43.373494016Z,1.0509336990511986,0.3569541423061231,0.33965429277640213,normal
,,5,0.5035714544702937,5,example_data,2020-04-29T13:00:43.373494016Z,1,0.33965429277640213,0.33965429277640213,normal
,,5,0.5035714544702937,6,example_data,2020-04-29T13:00:43.373494016Z,1.9085941171497334,0.6482621850576943,0.33965429277640213,normal
,,5,0.5035714544702937,7,example_data,2020-04-29T13:00:43.373494016Z,0.5730916557767362,0.1946530410389046,0.33965429277640213,normal
,,5,0.5035714544702937,8,example_data,2020-04-29T13:00:43.373494016Z,0.6987489651154969,0.237333085574547,0.33965429277640213,normal
,,5,0.5035714544702937,9,example_data,2020-04-29T13:00:43.373494016Z,0.5199623787666707,0.17660745403032926,0.33965429277640213,normal
,,5,0.5035714544702937,outlier,example_data,2020-04-29T13:00:43.373494016Z,0,0,0.33965429277640213,normal
,,6,0.36830737628858845,0,example_data,2020-04-30T00:40:28.915662592Z,1,0.24841992195372214,0.24841992195372214,normal
,,6,0.36830737628858845,1,example_data,2020-04-30T00:40:28.915662592Z,0.790421352898622,0.19635641079763116,0.24841992195372214,normal
,,6,0.36830737628858845,2,example_data,2020-04-30T00:40:28.915662592Z,1.1507707237293252,0.28587437337546734,0.24841992195372214,normal
,,6,0.36830737628858845,3,example_data,2020-04-30T00:40:28.915662592Z,0.44898657888440013,0.1115372108847314,0.24841992195372214,normal
,,6,0.36830737628858845,4,example_data,2020-04-30T00:40:28.915662592Z,0,0,0.24841992195372214,normal
,,6,0.36830737628858845,5,example_data,2020-04-30T00:40:28.915662592Z,0.8924336465340472,0.22169829682086367,0.24841992195372214,normal
,,6,0.36830737628858845,6,example_data,2020-04-30T00:40:28.915662592Z,1.1113146283494955,0.2760726932406114,0.24841992195372214,normal
,,6,0.36830737628858845,7,example_data,2020-04-30T00:40:28.915662592Z,0.23467699757429752,0.05829844142174083,0.24841992195372214,normal
,,6,0.36830737628858845,8,example_data,2020-04-30T00:40:28.915662592Z,1.9734653188532179,0.49024810048789375,0.24841992195372214,normal
,,6,0.36830737628858845,9,example_data,2020-04-30T00:40:28.915662592Z,2.486584235715475,0.6177170617677941,0.24841992195372214,normal
,,6,0.36830737628858845,outlier,example_data,2020-04-30T00:40:28.915662592Z,1.6489005131963252,0.4096197367976835,0.24841992195372214,normal
,,7,0.20077292063886873,0,example_data,2020-04-30T12:20:14.457831424Z,0,0,0.13541947972404475,normal
,,7,0.20077292063886873,1,example_data,2020-04-30T12:20:14.457831424Z,1.3280932676717847,0.1798496993331196,0.13541947972404475,normal
,,7,0.20077292063886873,2,example_data,2020-04-30T12:20:14.457831424Z,0.3544766453164316,0.04800304288307591,0.13541947972404475,normal
,,7,0.20077292063886873,3,example_data,2020-04-30T12:20:14.457831424Z,2.4449385480706254,0.3310923061369855,0.13541947972404475,normal
,,7,0.20077292063886873,4,example_data,2020-04-30T12:20:14.457831424Z,0.7470534124611492,0.10116558444156104,0.13541947972404475,normal
,,7,0.20077292063886873,5,example_data,2020-04-30T12:20:14.457831424Z,0.537669190791584,0.07281088208064446,0.13541947972404475,normal
,,7,0.20077292063886873,6,example_data,2020-04-30T12:20:14.457831424Z,1.8334818102316615,0.24828915282507133,0.13541947972404475,normal
,,7,0.20077292063886873,7,example_data,2020-04-30T12:20:14.457831424Z,2.404044964672827,0.32555451834920374,0.13541947972404475,normal
,,7,0.20077292063886873,8,example_data,2020-04-30T12:20:14.457831424Z,1.442798896224032,0.19538307587308443,0.13541947972404475,normal
,,7,0.20077292063886873,9,example_data,2020-04-30T12:20:14.457831424Z,1,0.13541947972404475,0.13541947972404475,normal
,,7,0.20077292063886873,outlier,example_data,2020-04-30T12:20:14.457831424Z,0.6780820622669829,0.09182552008240213,0.13541947972404475,normal
",
            )

        testing.diff(got: got, want: want)
    }
