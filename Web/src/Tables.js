import React from "react";
import { Table, Button, Row, Col } from 'reactstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faEdit, faTrashAlt } from '@fortawesome/free-solid-svg-icons';
import { Image } from "react-bootstrap";
import ModalPage3 from './ModalPage3';
import './Table.css';
import { db } from './Firebase-config';
import { collection, getDocs, query, where, deleteDoc, doc } from 'firebase/firestore'
class Tables extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: [],
      modal1: false,
      shopid:'fudW345dIWWYj9YUKRgR',
      id:''
    }
  }
  componentDidMount() {
    // const itemcollectionref=collection(db,"products");
    // const getUser=async () => {
    //   const data=await getDocs(itemcollectionref);
    // // this.setState({})
    // console.log(data);
    this.fetchMessages();
  }
  fetchMessages = async () => {
    async function getCities(db) {
      const prod = collection(db, 'products');
      const q = query(prod, where("shop_id", "==", "fudW345dIWWYj9YUKRgR"));
      const citySnapshot = await getDocs(q);
      const cityList = citySnapshot.docs.map(doc => doc.data());
      // console.log(cityList);
      return cityList;
    }
    var hello = await getCities(db);
    // console.log(hello);
    this.setState({
      data: hello,
      id:''
    })
  }
  openModal = (e, pid) => {
    console.log(pid);
    this.setState((prevState) => {
      return { id: pid, modal: !prevState.modal }
    });
  }
  toggle1 = () => {

  }
  gotToconfirm = (e, pid) => {

  }
  deleteconfirm = (e, pid) => {

  }
  deleteItem = async (e, pid) => {
    async function deleteval(db, pid) {
      const proddoc = doc(db, 'products', pid);
      var wishlist=collection(db,'wishlist');
      var query1 = query(wishlist, where("item_id", "==", pid));
      const snaps=await getDocs(query1);
      snaps.docs.map((docsval) => {
        // console.log(docsval.data().key);
        var docval=doc(db,'wishlist',docsval.data().key);
         var temp2=deleteDoc(docval);
        // console.log(doc.data());
      });
        // querySnapshot.forEach(function (doc) {
        //   doc.ref.delete();
        // });
      // });
      // const temp1 = await deleteDoc(wishlist);
      const temp = await deleteDoc(proddoc);
      return 1  ;
    }
    var val = await deleteval(db, pid);
    // console.log(val);
    this.fetchMessages();
  }
  render() {
    return (
      <div>
        <Table hover>
          <thead>
            <tr>
              <th>
                Product
      </th>
              <th>
                Name
      </th>
              <th>
                Availability
      </th>
              <th>
                Price
      </th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {
              this.state.data.map((value, index) => {
                return (
                  <tr>
                    <th scope="row" >
                      <Image className="wrapper-image" src={value.p_image} rounded />
                    </th>
                    <td>
                      {value.p_name}
                    </td>
                    <td>
                      {value.availability ? 'Available' : 'Not available'}
                    </td>
                    <td>
                      {value.price}
                    </td>
                    <td>
                      <Row className="tableicon">
                        {/* {console.log(value.p_id)} */}
                        <Col className="col-1 editbut" id={value.p_id} onClick={e => {
                          this.openModal(e, value.p_id)
                        }}>
                          {/* {console.log(value.p_id)} */}
                          <FontAwesomeIcon icon={faEdit} />
                        </Col>
                        <Col className="col-1 deletebut" id={value.p_id} onClick={e => {
                          this.deleteItem(e, value.p_id)
                        }} >
                          <FontAwesomeIcon icon={faTrashAlt} />
                        </Col>
                      </Row>
                    </td>
                  </tr>
                )
              })}
          </tbody>
        </Table>
        <ModalPage3 id={this.state.id} boolval={this.state.modal} shopid={this.state.shopid}/>
        {/* <Modal isOpen={this.state.modal1}
                    toggle={this.toggle1}
                    centered
                    >
                        <ModalHeader toggle={this.toggle1}>
                        Add new Product
                        </ModalHeader>
                    <ModalBody>
                      Do you want to delete?
                    </ModalBody>
                    <ModalFooter>
                        {' '}
                        <Button color='primary' outline onClick={this.deleteconfirm}>
                            Submit
      </Button>
                        <Button onClick={this.toggle1}>
                            Cancel
      </Button>
                    </ModalFooter>
                </Modal> */}
      </div>
    );
  }
}

export default Tables;