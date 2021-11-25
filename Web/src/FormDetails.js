import React from 'react';
import { Button, Form, FormGroup, FormText, Input, Label } from 'reactstrap';
import { db } from './Firebase-config';
import { collection,setDoc, getDocs, query, where, deleteDoc, doc } from 'firebase/firestore'

class FormDetails extends React.Component {
    constructor(props){
        super(props)
        // console.log(props);
        this.state={
            data:props.data,
            nametext:"",
            price:null,
            boolval:false,
            imageurl:null,
            select1:false,
            select2:true,
            selectedFile:null
        }
    }
    componentDidMount(){
        if(this.props.id){
            const fetch=async()=>{
            const prod = collection(db, 'products');
            const q = query(prod, where("p_id", "==", this.props.id));
            const citySnapshot = await getDocs(q);
            const cityList = citySnapshot.docs.map(doc => doc.data());
            // console.log(cityList);
            this.setState({
                nametext:cityList[0].p_name,
                select1:cityList[0].availability,
                select2:!cityList[0].availability,
                price:Number(cityList[0].price)
            })
            }
            fetch();
        }
    }
    componentWillReceiveProps(nextProps) {
        if (nextProps.id !== this.props.id) {
          console.log(nextProps);
        console.log('test')
          if(nextProps.id){
                    const fetch=async()=>{
                    const prod = collection(db, 'products');
                    const q = query(prod, where("p_id", "==", nextProps.id));
                    const citySnapshot = await getDocs(q);
                    const cityList = citySnapshot.docs.map(doc => doc.data());
                    // console.log(cityList);
                    
                    this.setState({
                        nametext:cityList[0].p_name,
                        select1:cityList[0].availability,
                        select2:!cityList[0].availability,
                        price:Number(cityList[0].price)
                    })
                    }
                    fetch();
                }
          
        //   this.selectNew();
        }
      }
    inputread=(e)=>{
        // console.log(e);
        this.setState({
            nametext:e.target.value
        })
    }
    priceread=(e)=>{
        // console.log(e);
        this.setState({
            price:e.target.value
        })
    }
    radiobut=(e)=>{
        this.setState((prevState) => {
            return { select1: !prevState.select1,select2:!prevState.select2 }
        },()=>{
            // console.log(this.state.select1);
        });
    }
    onFileChange = event => {
    
        // console.log(event.target.files);
        this.setState({ selectedFile: event.target.files[0] });
      
      };
    //   getUrl=async (file)=>{

    //   }
    setData=async (e)=>{
        // console.log(file['file']);
        // const imgurl= await getUrl(this.state.selectedFile);
        const data={
            p_name:this.state.nametext,
            availability:this.state.select1,
            price:Number(this.state.price),
            p_image:'https://dummyimage.com/250/ffffff/000000',
            shop_id:this.props.shopid
        }
        // console.log(this.props.id);
        if(!this.props.id){
        const newCityRef = doc(collection(db, "products"));
        // console.log(newCityRef._key.path.segments[1]);
        data['p_id']=newCityRef._key.path.segments[1];
        var val=await setDoc(newCityRef, data);
        this.props.closeModal();
        }else{
            // console.log(data);
            data['p_id']=this.props.id;
            const newCityRef = doc(db, "products",this.props.id);
            var val=await setDoc(newCityRef, data);
        // update(ref(db), updates);
        this.props.closeModal();
        }
    }
    render() {
        return (
            <Form inline>
                <FormGroup>
                    <Label
                        for="exampleEmail"
                        hidden
                    >
                        Name
                </Label>
                    <Input
                        id="productname"
                        name="name"
                        placeholder="Name"
                        type="text"
                        value={this.state.nametext}
                        onChange={this.inputread}
                    />
                </FormGroup>
                {' '}
                <FormGroup>
                    <Label
                        for="examplePassword"
                        hidden
                    >
                        price
                    </Label>
                    <Input
                        id="productprice"
                        name="price"
                        placeholder="Price"
                        type="Number"
                        value={this.state.price}
                        onChange={this.priceread}
                    />
                </FormGroup>
                {' '}
                <FormGroup check>
                    <Input
                        name="radio1"
                        type="radio"
                        // {this.state.data?this.state.data.Name:''}
                        // {}
                        onChange={this.radiobut}
                        checked={this.state.select1?'checked':null}
                    />
                    {' '}
                    <Label check>
                        Available
                </Label>
                </FormGroup>
                <FormGroup check>
                    <Input
                        name="radio1"
                        type="radio"
                        onChange={this.radiobut}
                        checked={this.state.select2?'checked':null}
                    />
                    {' '}
                    <Label check>
                        Not Available
                </Label>
                </FormGroup>
                <FormGroup>
                    <Label for="exampleFile">
                        Upload image
                    </Label>
                    <Input
                        id="exampleFile"
                        name="file"
                        type="file"
                        onChange={this.onFileChange}
                    />
                    <FormText>
                        Add images of the product in png,jpeg or jpg format for display.
                    </FormText>
                </FormGroup>
                <Button color="primary" outline onClick={this.setData}>Submit</Button>
            </Form>
        );
    }
}
export default FormDetails;