/**
 * Created by pcts on 1/13/2017.
 */
/**
 * Created by pcts on 1/11/2017.
 */
import React, { Component } from 'react';
import { Modal, Text, TouchableHighlight, View,TextInput,Button  } from 'react-native';
import {connect} from 'react-redux';
import { ActionCreators } from '../actions'
import { bindActionCreators } from 'redux'

class Test extends  React.Component {

    _onPress(){

        this.props.test("YOLO",this.props.index);
        /*
        * export function test(name,index) {
         return {
         type: types.TEST,
         name,
         index,
         }
         }

      deixa ver a funcionar para ver se é o que estou a pensar
        * */
    }

    render(){
        console.log("render"+this.props.text +"INDEX "+this.props.index);

        return (
            <View>
                <Button title={"teste "+this.props.text} onPress={this._onPress.bind(this)}>

                </Button>
            </View>
        );

    }
}

function mapDispatchToPros(dispatch) {
    return bindActionCreators(ActionCreators, dispatch);
}

export default connect((state,ownProps)=> {

    return {
        text: state.manel[ownProps.index]

    }}, mapDispatchToPros)(Test);