import React, { useState, useEffect } from 'react';

import { TimeSeries, TimeRange } from "pondjs";
import { Charts, ChartContainer, ChartRow, YAxis, LineChart, Resizable, styler } from "react-timeseries-charts";

import axios from 'axios';

function ChannelScore() {
  const [scoreTimeSeries, setScoreTimeSeries] = useState()
  const [range, setRange] = useState(new TimeRange([new Date(0), new Date(1)]))
  const scoreStyle = styler([{ key: "score", color: "#208C36", width: 3}]);

  useEffect( () => {
    axios.get(window.location.origin + '/api/score/vinesauce')
         .then(res => {
           const data = res.data;
           console.log(data)
           if (data.length > 0) {
             const datapoints = data[0].datapoints.filter((item) => item[0] != null)
                                                  .map((item) => [item[1]*1000, item[0]])
             const series = new TimeSeries({
               name: "vassast",
               columns: ["time", "score"],
               points: datapoints
             })
             setScoreTimeSeries(series);
             setRange(series.timerange())
           }
         })
    }, []);

  return (
    <ChartContainer timeRange={range}>
      <ChartRow height="200">
        <YAxis
          id="axis1"
          label="Score"
          min={scoreTimeSeries ? scoreTimeSeries.min("score") : 0}
          max={scoreTimeSeries ? scoreTimeSeries.max("score") : 50} width="60" type="linear"/>
        <Charts>
          <LineChart
            axis="axis1"
            interpolation="curveBasisOpen"
            style={scoreStyle}
            series={scoreTimeSeries ? scoreTimeSeries : new TimeSeries()}
            columns={["score"]}/>
        </Charts>
      </ChartRow>
    </ChartContainer>
  )
}

export default ChannelScore;
