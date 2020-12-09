import React, { useState, useEffect } from 'react';

import { TimeSeries, TimeRange } from "pondjs";
import { Charts, ChartContainer, ChartRow, YAxis, LineChart } from "react-timeseries-charts";

import axios from 'axios';

// Array [ 4, 1607452320 ]

function ChannelScore() {
  const [scoreTimeSeries, setScoreTimeSeries] = useState()
  const [range, setRange] = useState(new TimeRange([new Date(0), new Date(1)]))

  useEffect( () => {
    axios.get(window.location.origin + '/api/score/vinesauce')
         .then(res => {
           const data = res.data;
           console.log(data)
           const datapoints = data[0].datapoints.filter((item) => item[0] != null)
                                                .map((item) => [item[1]*1000, item[0]])
           const series = new TimeSeries({
             name: "vassast",
             columns: ["time", "score"],
             points: datapoints
           })
           setScoreTimeSeries(series);
           setRange(series.timerange())
           console.log(datapoints)
         })
    }, []);

  return (
    <div style={{
        position: 'absolute', left: '50%', top: '50%',
        transform: 'translate(-50%, -50%)'
    }}>
      <ChartContainer timeRange={range} width={800}>
        <ChartRow height="200">
          <YAxis
            id="axis1"
            label="Score"
            min={scoreTimeSeries ? scoreTimeSeries.min("score") : 0}
            max={scoreTimeSeries ? scoreTimeSeries.max("score") : 50} width="60" type="linear"/>
          <Charts>
            <LineChart
              axis="axis1"
              series={scoreTimeSeries ? scoreTimeSeries : new TimeSeries()}
              columns={["score"]}/>
          </Charts>
        </ChartRow>
      </ChartContainer>
    </div>
  )
}

export default ChannelScore;
