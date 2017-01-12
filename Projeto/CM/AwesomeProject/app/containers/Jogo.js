/**
 * Created by pcts on 1/11/2017.
 */
import React, { Component } from 'react';
import { Modal, Text, TouchableHighlight, View,TextInput,Button  } from 'react-native';
import {connect} from 'react-redux';

class Jogo extends React.Component{

    constructor(props){
        super(props);

        this.state = {
            username : this.props.username,
            serverConfirmationToStart : false,
            socket : this.props.socket,
            game : this.props.game,
            winner : false,
            loser : false,
            turn : ""
        }
    }

    componentDidMount(){
        this.state.socket.emit('gameReady');
        this.state.socket.on('userLeave',this._winner.bind(this));
        this.state.socket.on('start',this._startGame.bind(this));
    }

    componentWillUnmout(){
        this.state.socket.removeAllListeners('userLeave');
        this.state.socket.removeAllListeners('start');
    }

    _winner(){
        this.setState({
            winner: true
        });
    }

    _loser(){
        this.setState({
            loser: true
        });
    }

    _startGame(){
        this.setState({
            serverConfirmationToStart:true
        });
    }


    render(){

        if (this.state.winner){
            return <Winner/>
        }

        if (this.state.loser){
            return <Loser/>
        }

        if (!this.state.serverConfirmationToStart){
            return <Waiting/>
        }


        return <View><Text>JOGO</Text></View>;
    }

}


export default connect((store)=>{
    return {
      socket:store.socket,
      game:store.game,
      username: store.username
    };
})(Jogo);



class Winner extends React.Component {

    render(){
      return  <View>
            <Text>Winner!</Text>

        </View>
    }

}

class Loser extends React.Component {

    render(){
       return <View>
            <Text>Loser!</Text>

        </View>
    }

}

class Waiting extends React.Component {

    render(){
      return  <View>
            <Text>Starting game...</Text>

        </View>
    }

}