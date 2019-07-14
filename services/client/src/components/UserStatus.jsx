import React, {Component} from 'react';
import PropTypes from 'prop-types';
import {Link} from 'react-router-dom';
import axios from 'axios';

class UserStatus extends Component {
    constructor(props) {
        super(props);
        this.state = {
            email: '',
            id: '',
            username: ''
        };
    };

    componentDidMount() {
        if (this.props.isAuthenticated) {
            this.getUserStatus();
        }
    };

    getUserStatus(event) {
        const options = {
            url: `${process.env.REACT_APP_USERS_SERVICE_URL}/auth/status`,
            method: 'get',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${window.localStorage.authToken}`
            }
        };
        return axios(options)
            .then((res) => {
                // new
                this.setState({
                    email: res.data.data.email,
                    id: res.data.data.id,
                    username: res.data.data.username
                })
            })
            .catch((error) => { console.log(error); });
    };

    render() {
        // new
        if (!this.props.isAuthenticated) {
            return (
                <p>You must be logged in to view this. Click <Link to="/login">here</Link> to log back in.</p>
            )
        }
        ;

        return (
            <div>
                <ul>
                    <li><strong>User ID:</strong> {this.state.id}</li>
                    <li><strong>Email:</strong> {this.state.email}</li>
                    <li><strong>Username:</strong> {this.state.username}</li>
                    <li><strong>Active:</strong> {this.state.active}</li>
                    <li><strong>Admin:</strong> {this.state.admin}</li>
                </ul>
            </div>
        )
    };
};

UserStatus.propTypes = {
    isAuthenticated: PropTypes.bool.isRequired,
};

export default UserStatus;