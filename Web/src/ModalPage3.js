import React from 'react';
import {
    Button, Modal, ModalFooter,
    ModalHeader, ModalBody
} from "reactstrap";
import FormDetails from './FormDetails';
class ModalPage3 extends React.Component {
    constructor(props) {
        super(props);
        console.log(props)
        console.log('hello');
        this.state = {
            modal: false,
            id:props.id,
            data:props.data,
            shopid:props.shopid
        }
    }
    componentWillReceiveProps(nextProps) {
        if (nextProps !== this.props) {
          this.setState({ modal: nextProps.boolval,id:nextProps.id ,shopid:nextProps.shopid});
        //   console.log(nextProps);
        //   this.selectNew();
        }
      }
    toggle = () => {
        this.setState((prevState) => {
            return { modal: !prevState.modal }
        });
    }
    render() {
        return (
            <div style={{
                display: 'block'
            }}>
                {/* <Button color="primary"
                    onClick={this.toggle}>Open Modal</Button> */}
                <Modal isOpen={this.state.modal}
                    toggle={this.toggle}
                    centered
                    >
                        <ModalHeader toggle={this.toggle}>
                        Edit products
                        </ModalHeader>
                    <ModalBody>
                        <FormDetails id={this.state.id} closeModal={this.toggle} shopid={this.state.shopid}/>
                    </ModalBody>
                    <ModalFooter>
                        {' '}
                        <Button onClick={this.toggle}>
                            Cancel
      </Button>
                    </ModalFooter>
                </Modal>
            </div >
        );
    }
}

export default ModalPage3;