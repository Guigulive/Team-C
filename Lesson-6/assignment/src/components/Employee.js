import React, { Component } from 'react'
import { Card, Col, Row, Layout, Alert, message, Button } from 'antd';

import Common from './Common';

class Employee extends Component {
  constructor(props) {
    super(props);
    this.state = {
      salary: 0,
      lastPaidDate: '',
      balance: 0,
    };
  }

  componentDidMount() {
    this.checkEmployee();
  }

  checkEmployee = () => {
    const { account, payroll, web3 } = this.props;

    payroll.employees.call(account, {from: account})
    .then((result) => {
      const salary = web3.fromWei(result[1].toNumber());
      const lastPaidDate = Date(result[2].toNumber() * 1000);
      this.setState({
        salary: salary,
        lastPaidDate: lastPaidDate,
      });
    })
    .catch((err) => {
      console.log('fail to check employee, err: ' + err);
    });

    web3.eth.getBalance(account, (err, bal) => {
      if (err) {
        console.log('fail to get balance, err: ' + err);
      } else {
        const balance = web3.fromWei(bal.toNumber());
        this.setState({
          balance: balance,
        });
      }
    });
  }

  getPaid = () => {
    const { account, payroll, web3 } = this.props;

    payroll.getPaid({from: account, gas: 5000000})
    .then(() => {
      alert('get paid successful!');
      this.checkEmployee();
    })
    .catch((err) => {
      console.log('fail to get paid, err: ' + err);
    });
  }

  renderContent() {
    const { salary, lastPaidDate, balance } = this.state;

    if (!salary || salary === '0') {
      return (
        <div>
          <Alert message="你不是员工" type="error" showIcon />
        </div>
      );
    }

    return (
      <div>
        <Row gutter={16}>
          <Col span={8}>
            <Card title="薪水">{salary} Ether</Card>
          </Col>
          <Col span={8}>
            <Card title="上次支付">{lastPaidDate}</Card>
          </Col>
          <Col span={8}>
            <Card title="帐号金额">{balance} Ether</Card>
          </Col>
        </Row>

        <Button
          type="primary"
          icon="bank"
          onClick={this.getPaid}
        >
          获得酬劳
        </Button>
      </div>
    );
  }

  render() {
    const { account, payroll, web3 } = this.props;

    return (
      <Layout style={{ padding: '0 24px', background: '#fff' }}>
        <Common account={account} payroll={payroll} web3={web3} />
        <h2>个人信息</h2>
        {this.renderContent()}
      </Layout >
    );
  }
}

export default Employee
