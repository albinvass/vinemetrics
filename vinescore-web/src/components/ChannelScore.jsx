import React, { useState, useEffect } from 'react';

import { TimeSeries, TimeRange } from "pondjs";
import { Charts, ChartContainer, ChartRow, YAxis, LineChart } from "react-timeseries-charts";

import axios from 'axios';

// Array [ 4, 1607452320 ]

function ChannelScore() {
  const [scoreTimeSeries, setScoreTimeSeries] = useState(new TimeSeries())
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
    <ChartContainer timeRange={range} width={800}>
      <ChartRow height="200">
        <YAxis id="axis1" label="Score" min={-50} max={100} width="60" type="linear"/>
        <Charts>
          <LineChart axis="axis1" series={scoreTimeSeries} columns={["score"]}/>
        </Charts>
      </ChartRow>
    </ChartContainer>
  )
}

export default ChannelScore;
