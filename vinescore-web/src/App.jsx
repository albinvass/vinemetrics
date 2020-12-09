import { Paper } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';

import './App.css';
import ChannelScore from './components/ChannelScore';

const useStyles = makeStyles({
  root: {
    background: '#0C0E0C',
    border: 0,
    borderRadius: 3,
    color: 'white',
    alignSelf: 'flex-start',
    padding: '10px'
  },
});

function App() {
  const classes = useStyles();
  return (
    <div className="App">
      <div
        style={{
          position: 'absolute', left: '50%', top: '50%',
          transform: 'translate(-50%, -50%)',
        }}
      >
        <Paper className={classes.root} elevation={3}>
          <ChannelScore/>
        </Paper>
    </div>
    </div>
  );
}

export default App;
