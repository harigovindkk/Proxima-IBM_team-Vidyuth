import React from 'react';
import { Badge, Button, Form, FormGroup, FormText, Input, Label } from 'reactstrap';
import { geolocated } from "react-geolocated";
import { Textarea } from '@geist-ui/react';
import { collection, getDocs, query, where, deleteDoc, doc } from 'firebase/firestore'
import {db} from './Firebase-config';
class ProfileModal extends React.Component {
    constructor(props){
        super(props);
        this.state ={
            latitude:null,
            longitude:null,
            useraddress:null,
            name:''
        }
    }
    componentDidMount() {
    this.fetchMessages();
      }
      fetchMessages = async () => {
        async function getCities(db) {
            const prod = collection(db, 'shops');
            const q = query(prod, where("id", "==", "fudW345dIWWYj9YUKRgR"));
            const citySnapshot = await getDocs(q);
            const cityList = citySnapshot.docs.map(doc => doc.data());
            // console.log("hello kutta")
            // console.log(cityList);
            return cityList;
          }
        var hello = await getCities(db);
        // console.log(hello);
        this.setState({
          useraddress:hello[0].address,
          name:hello[0].name,
          latitude:hello[0].location._lat,
          longitude:hello[0].location._long
        })
      }

    getLocation=()=>{
        navigator.geolocation.getCurrentPosition((position) =>{
            if(position.coords.latitude){
        this.setState({lattiude:position.coords.latitude,longitude:position.coords.longitude});
            }
        });
    }
    render() {
        return (
            <Form inline>
                <FormGroup>
                    <Label
                        for="exampleEmail"
                        hidden
                    >
                        Shop Name
                </Label>
                    <Input
                        id="productname"
                        name="name"
                        placeholder="ShopName"
                        type="text"
                        value={this.state.name}
                    />
                </FormGroup>
                {' '}
                <FormGroup>
                <Label
                        for="examplePassword"
                        hidden
                    >
                        text area
                    </Label>
                    <Input
      id="exampleText"
      name="text"
      type="textarea"
      placeholder="Address"
      value={this.state.useraddress}
    />
                </FormGroup>
                {' '}
                <FormGroup>
                    <Label for="exampleFile" className="mr-2">
                        Update your location
                    </Label>
                    <br />
                    <Button outline color="primary" onClick={this.getLocation}>Get Location</Button>
                </FormGroup>

                <FormGroup>
                    {this.state.latitude?<Label >
                        <Badge
                        color="primary"
                        pill
                        > lattitude: {this.state.latitude}</Badge>
                        
                        <Badge
                        color="primary"
                        pill
                        >longitude:{this.state.longitude}
                        </Badge> <br/>
                    </Label> :null}
                </FormGroup>
                <Button>
                    Submit
                </Button>
            </Form>
        );
    }
}
export default ProfileModal;