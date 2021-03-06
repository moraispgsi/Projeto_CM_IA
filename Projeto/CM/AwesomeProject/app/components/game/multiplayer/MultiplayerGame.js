import React, {Component} from 'react';
import {Modal, Text, TouchableHighlight,BackAndroid, View, TextInput, Button} from 'react-native';
import {connect} from 'react-redux';
import WinScreen from './WinScreen';
import Score from './Score';
import DrawScreen from './DrawScreen';
import LostScreen from './LostScreen';
import WinForfeitScreen from './WinForfeitScreen';
import Board from '../../board/Board';
import BoardModel from'../../../models/BoardModel';
import {ActionCreators} from '../../../actions'
import {bindActionCreators} from 'redux'
import { Actions } from 'react-native-router-flux'

class MultiplayerGame extends React.Component {

    constructor(props) {
        super(props);

        this.state = {
            serverConfirmationToStart: false,
            hasWinner: false,
            haveIWon: false,
            isDraw: false,
            isForfeit: false,
            width: 0,
            height: 0,
            scorePlayer1: 0,
            scorePlayer2: 0,
            board: null
        }
    }

    componentDidMount() {
        this.props.socket.on('userLeave', this._userLeave.bind(this));
        this.props.socket.on('start', this._startGame.bind(this));
        this.props.socket.on('receiveMove', this._receiveMove.bind(this));
        this.props.socket.emit('gameReady');


         let handler = function() {
            // this.onMainScreen and this.goBack are just examples, you need to use your own implementation here
            // Typically you would use the navigator here to go to the last state.
            this.props.socket.emit('forfeit', {});
            BackAndroid.removeEventListener('hardwareBackPress', handler);
             Actions.salas({type: 'reset'});
            this.props.socket.emit('logToServer', 'User back button pressed');
            return true;



        }.bind(this);

        BackAndroid.addEventListener('hardwareBackPress', handler);
    }

    componentWillUnmount() {
        this.props.socket.removeAllListeners('userLeave');
        this.props.socket.removeAllListeners('start');
        this.props.socket.removeAllListeners('receiveMove');
        this.props.socket.removeAllListeners('ackMove');
        this.props.socket.emit('logToServer', 'UNMOUNTED');
    }

    componentWillUpdate() {
        return true;
    }

    checkWinner(newState){

        if (newState.board.isFilled()){
            let winner = newState.board.getCurrentWinner('player1', 'player2');
            newState.hasWinner = true;
            newState.haveIWon = winner == 'player1';
            newState.isDraw = winner == null;
            this.setState(newState);
        }



        return newState;
    }

    _userLeave(){
        let newState = Object.assign({}, this.state);
        newState.hasWinner = true;
        newState.isForfeit = true;
        this.setState(newState);

        this.props.socket.emit('logToServer', 'User leave received');
    }

    _startGame(data) {
        let info = data.gameInfo;
        this.props.startGame(info);

        this.state.board = new BoardModel(info.hSquares, info.vSquares);
        this.props.socket.emit('logToServer', 'START GAME');

        this.state.board.setEdgesOnClick(function (edge) {

            if (edge.isClosed)
                return;

            this.state.board.disableEdges();

            //Prepares for move ack
            this.props.socket.on('ackMove', function (data) {

                let closedSquares =  edge.setClosed('player1');
                let newState = Object.assign({}, this.state);

                if (closedSquares > 0) {
                    this.state.board.enableEdges();
                    newState.scorePlayer1 += closedSquares;
                    this.setState(newState);
                }

                this.checkWinner(newState);

            }.bind(this));

            //Makes the move in the server
            this.props.socket.emit('makeMove', {
                gameID: data.gameInfo.id,
                edge: edge.orientation == 'horizontal' ? 0 : 1,
                row: edge.row,
                column: edge.column,
            });

        }.bind(this));

        this.state.serverConfirmationToStart = true;

        if (info.turn != this.props.username) {
            this.state.board.disableEdges();
        }

        this.setState(this.state);
    }

    //On receive a move made from an opponent
    _receiveMove(move) {

        let edges = move.edge == 0 ? this.state.board.horizontalEdges : this.state.board.verticalEdges;

        let closedSquares = edges[move.row][move.column].setClosed('player2');

        let newState = Object.assign({}, this.state);

        if (closedSquares == 0){
            newState.board.enableEdges();
        } else {
            newState.scorePlayer2 += closedSquares;
        }

        this.setState(newState);

        //Send ack after receiving the move
        this.props.socket.emit('ackReceiveMove', {
            ack: {
                gameID: move.gameID
            }
        });

        this.checkWinner(newState);

    }

    render() {


        let onLayout = (event) => {

            let width = event.nativeEvent.layout.width;
            let height = event.nativeEvent.layout.height;

            if(this.state.width == width &&
                this.state.height == height) {
                return;
            }

            this.state.width = width;
            this.state.height = height;
            this.setState(this.state);
        };

        let isPortrait = true;
        if(this.state.width > this.state.height)
            isPortrait = false;

        let styleBoardBaseContainer = {};
        let styleBoardContainer = {};
        let styleScoreContainer = {};
        let styleScore1 = {};
        let styleScore2 = {};

        if(isPortrait){

            styleBoardBaseContainer = styles.basePortrait;

            let min = Math.min(this.state.width, this.state.height) - 40;
            styleBoardContainer = {
                width: min + 40,
                height: min + 40,
                paddingTop: 20,
                paddingBottom: 20,
                paddingLeft : 20,
                paddingRight : 20,
            }

            let scoreContainerHeight = this.state.height - this.state.width;

            styleScoreContainer = {
                height: scoreContainerHeight,
                flex: 1,
                flexDirection: 'row',
                backgroundColor: 'black',
            }

            styleScore1 = {
                width: this.state.width / 2,
                height: scoreContainerHeight,
            }

            styleScore2 = {
                width: this.state.width / 2,
                height: scoreContainerHeight,
            }


        } else {

            styleBoardBaseContainer = styles.baseLandscape;

            let min = Math.min(this.state.width, this.state.height) - 40;
            styleBoardContainer = {
                width: min + 40,
                height: min + 40,
                paddingTop: 20,
                paddingBottom: 20,
                paddingLeft : 20,
                paddingRight : 20,
            }


            let scoreContainerWidth = this.state.width - this.state.height;

            styleScoreContainer = {
                width: scoreContainerWidth,
                flex: 1,
                flexDirection: 'column',
                backgroundColor: 'black',
            }

            styleScore1 = {
                width: scoreContainerWidth,
                height: this.state.height / 2,
            }

            styleScore2 = {
                width: scoreContainerWidth,
                height: this.state.height / 2,
            }
        }


        if (this.state.hasWinner) {

            if(this.state.isDraw){
                return <View
                    onLayout={onLayout} style={[styleBoardBaseContainer]}>
                    <DrawScreen width={this.state.width}
                               height={this.state.height}/></View>
            }

            if(this.state.isForfeit){
                return <View
                    onLayout={onLayout} style={[styleBoardBaseContainer]}>
                    <WinForfeitScreen width={this.state.width}
                                height={this.state.height}/></View>
            }

            if(this.state.haveIWon){
                return <View
                             onLayout={onLayout} style={[styleBoardBaseContainer]}>
                                <WinScreen score={this.state.scorePlayer1}
                                           width={this.state.width}
                                           height={this.state.height}/></View>
            } else {
                return <View onLayout={onLayout} style={[styleBoardBaseContainer]}>
                            <LostScreen score={this.state.scorePlayer1}
                                        width={this.state.width}
                                        height={this.state.height}/>
                        </View>
            }

        }



        let opponent = this.props.username == this.props.player1 ? this.props.player2 : this.props.player1;

        return (
            <View onLayout={onLayout} style={[styleBoardBaseContainer]}>
                <View style={[styleScoreContainer]}>
                    <Score style={styleScore1} player={this.props.username} score={this.state.scorePlayer1} color="#3F9BBE"/>
                    <Score style={styleScore2} player={opponent} score={this.state.scorePlayer2}  color="#DC7F4A"/>
                </View>
                <View style={[styleBoardContainer]}>
                    <Board board={this.state.board} squaresHorizontal={this.props.hSquares} squaresVertical={this.props.vSquares} />
                </View>
            </View>
        );
    }

}

const styles = {
    basePortrait: {
        flex: 1,
        flexDirection: 'column',
        backgroundColor: '#F4F0E6',
    },
    baseLandscape: {
        flex: 1,
        flexDirection: 'row',
        backgroundColor: '#F4F0E6',
    }
};


//Redux store connect

function mapDispatchToPros(dispatch) {
    return bindActionCreators(ActionCreators, dispatch);
}

export default connect((store) => {
    return {
        hSquares: store.game.hSquares,
        vSquares: store.game.vSquares,
        socket: store.socket,
        username: store.username,
        player1: store.game.player1,
        player2: store.game.player2,
        turn: store.game.turn
    }
}, mapDispatchToPros)(MultiplayerGame);

