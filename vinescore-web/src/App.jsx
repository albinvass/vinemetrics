import { Paper, Container } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';

import './App.css';
import ChannelScore from './components/ChannelScore';

const useStyles = makeStyles({
  graphPaper: {
    background: '#0C0E0C',
    border: 0,
    borderRadius: 3,
    color: 'white',
    alignSelf: 'flex-start',
    padding: '100px'
  },
  graphBanner: {
    paddingBottom: '50px',
    fontSize: '24px'
  }
});

/*
 *
      <div
        style={{
          position: 'absolute', top: '50%',
          transform: 'translate(-50%, -50%)',
        }}
      >
      </div>
* */
function App() {
  const classes = useStyles();
  return (
    <div className="App">
      <Container maxWidth={'lg'}>
        <Paper className={classes.graphPaper} elevation={3}>
          <Container className={classes.graphBanner}>
            Hey Vinny say something funny.
          </Container>
          <ChannelScore/>
        </Paper>
      </Container>
    </div>
  );
}

export default App;
