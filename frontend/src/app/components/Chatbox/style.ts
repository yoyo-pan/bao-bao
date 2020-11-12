import { makeStyles } from '@material-ui/core'

export default makeStyles({
  container: {
    width: '100%',
    position: 'relative',
  },
  chatHistory: {
    height: '250px',
    'background-color': '#bbb',
    'border-radius': '15px 15px 0px 0px',
    'overflow-y': 'auto',
    display: 'flex',
    'flex-direction': 'column-reverse',
    transition: 'opacity 0.15s linear',
    '& ul': {
      padding: '0px 15px',
      'line-height': '2em',
      'list-style': 'none',
      '& .name': {
        color: 'yellow',
        width: '20em',
        '& span': {
          color: '#555',
          'font-size': '0.5em',
        },
      },
      '& .bubble': {
        padding: '0em 0.7em',
        margin: '0em 0.2em',
        'border-radius': '15px',
        'border-top-left-radius': '0px',
        'background-color': '#ccc',
      },
    },
  },
  historyBlur: {
    'background-color': 'rgba(0,0,0,0.1)',
    '& ul': {
      '& .name span': {
        color: '#FFF',
      },
      '& .bubble': {
        background: 'linear-gradient(left, rgba(200,200,200,1) 10px, rgba(200,200,200,0))',
      },
    },
  },
  chatInput: {
    width: '100%',
    transition: 'opacity 0.15s linear',
    '& input[type=text]': {
      position: 'absolute',
      width: '100%',
      padding: '1em 1.5em',
      display: 'inline-block',
      border: '1px solid #ccc',
      'border-radius': '4px',
      'box-sizing': 'border-box',
      '&:focus': {
        outline: 'none',
        border: '1px solid red',
      },
    },
    '& button': {
      position: 'absolute',
      height: '30px',
      margin: '7px -1em',
      right: '2em',
      width: '10%',
    },
  },
  inputBlur: {
    opacity: 0.7,
  },
})
