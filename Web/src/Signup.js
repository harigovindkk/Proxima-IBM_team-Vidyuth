import React from 'react'
import { Grid,Paper, Avatar, TextField, Button, Typography } from '@material-ui/core'
import LockOutlinedIcon from '@material-ui/icons/LockOutlined';
import PersonAddAlt1OutlinedIcon from '@mui/icons-material/PersonAddAlt1Outlined';
import {Link} from 'react-router-dom';
import {BrowserRouter as Router,Route,Switch } from 'react-router-dom';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Checkbox from '@material-ui/core/Checkbox';
const Signup=()=>{

    const paperStyle={padding :20,height:'70vh',width:400, margin:"20px auto"}
    const avatarStyle={backgroundColor:'#1bbd7e'}
    const btnstyle={margin:'8px 0'}
    return(
        <Grid>
            <Paper elevation={10} style={paperStyle}>
                <Grid align='center'>
                     <Avatar style={avatarStyle}><PersonAddAlt1OutlinedIcon/></Avatar>
                    <h2>Sign Up</h2>
                </Grid>
                <TextField label='Full Name' placeholder='Enter Fullname' fullWidth required/>
                <TextField label='Email' placeholder='Enter Email'  fullWidth required/>
                <TextField label='Password' placeholder='Enter password' type='password' fullWidth required/>
               
                <Button type='submit' color='primary' variant="contained" style={btnstyle} fullWidth>Sign up</Button>
                
                <Typography > Do you have an account ? 
                     <Link to={'/'}>
                        Sign In 
                </Link>
                </Typography>
            </Paper>
        </Grid>
    )
}

export default Signup