import { makeStyles } from '@material-ui/core'

const useStyle = makeStyles({
  mapArea: {
    width: '85%',
    display: 'inline-block',
    'text-align': 'center',
  },
  avatarArea: {
    width: '15%',
    display: 'inline-flex',
    position: 'absolute',
    'flex-direction': 'column',
  },
  chatArea: {
    position: 'fixed',
    left: 0,
    bottom: 45,
    width: '400px',
  },
  avatarCard: {
    height: '65px',
    margin: '5px 0px',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    '& .avatarIcon': {
      margin: 0,
      'background-color': '#3473D0',
      '&.me': {
        width: 55,
        height: 55,
        fontSize: 36,
        boxShadow: '0px 0px 7px rgba(0, 0, 0, 0.7)',
      },
      '&.dead': {
        backgroundColor: '#8c8c8c',
      },
    },
  },
})

export default useStyle
