import React from 'react';
import { CardTitle, CardText, Card, CardSubtitle, CardBody, Button,Row,Col } from 'reactstrap';
import ModalPage2 from './ModalPage2';
import {db} from './Firebase-config';
import { collection, getDocs, query, where, deleteDoc, doc } from 'firebase/firestore'
class CardDetail extends React.Component {
    constructor(props){
        super(props);
        this.state={
            name:null,
            shopname:null,
            shopaddress:null,
            boolval:false,
            location:null,
            shopid:'fudW345dIWWYj9YUKRgR'
        }
    }
    modalOpen=()=>{
        this.setState((prevState) => {
            return { modal: !prevState.modal }
        });
    }
    componentDidMount(){
        // async function getCities(db) {
        //     const prod = collection(db, 'shops');
        //     const q = query(prod, where("id", "==", "fudW345dIWWYj9YUKRgR"));
        //     const citySnapshot = await getDocs(q);
        //     const cityList = citySnapshot.docs.map(doc => doc.data());
        //     console.log(cityList);
        //     this.setState({
        //         shopname:cityList.name,
        //         shopaddress:cityList.shopaddress,
        //         name:'Name'
        //       });
        //     return cityList;
        //   }
        // //   var hello = await getCities(db);
        // //   console.log(hello);
        // getCities(db);
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
            //   var hello = await getCities(db);
            //   console.log(hello);
        var hello = await getCities(db);
        // console.log(hello[0]?.location);
        this.setState({
            shopname:hello[0].name,
            shopaddress:hello[0].address,
            location:hello[0].location,
            name:'Name'
          });
      }
    render() {
        return (
            <div>
                <Card
                    outline
                >
                    <CardBody>
                        <CardTitle tag="h5">
                            {this.state.name ? 'Welcome User': 'Please edit your profile :)'}
                        </CardTitle>
                        <CardSubtitle
                            className="mb-2 text-muted"
                            tag="h6"
                        >
                            Shop Name : {this.state.shopname}
                    </CardSubtitle>
                        <CardText>
                            <Row>
                                <Col className="col-10 pt-2">
                                 Shop address : {this.state.shopaddress}<br />
                                 {this.state.location?this.state.location._lat:null} {this.state.location?this.state.location._long:null}
                                </Col>
                                <Col className="col-2 pr-5">
                                <Button color="primary" outline onClick={this.modalOpen} >
                                    Edit profile    
                                </Button>
                                </Col>
                            </Row>
                            </CardText>
                        
                    </CardBody>
                </Card>
                <ModalPage2 boolval={this.state.modal} id={this.state.shopid}/>
            </div>
        );
    }
}
// export default CardDetail;



export default CardDetail;