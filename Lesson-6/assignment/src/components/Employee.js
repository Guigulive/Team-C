import React, { Component } from 'react'
import { Card, Col, Row, Layout, Alert, message, Button } from 'antd';

import Common from './Common';

class Employer extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidMount() {
    const updateInfo = (error, result) => {
      if (!error) {
        this.checkEmployee();
      }
    }
    const {payroll} = this.props;
     payroll.GetPaid(updateInfo);

    this.checkEmployee();
  }

  async checkEmployee() {
    const {payroll, account, web3} = this.props;
    console.info(account)
    let _this=this
    const self = await payroll.employees.call(account, {from:account})
    web3.eth.getBalance(account,function (error,balance) {
      console.log(balance)
      _this.setState({
        salary: web3.fromWei(self[1].toNumber()),
        lastPaidDate: new Date(self[2].toNumber() * 1000).toString(),
        balance:web3.fromWei(balance.toNumber())
      });
    })


  }

  getPaid = async() => {
    const {payroll, account} = this.props;
    await payroll.getPaid({from:account,})
    message.info('you have been paid');
  }

  renderContent() {
    const { salary, lastPaidDate, balance } = this.state;

    if (!salary || salary === '0') {
      return   <Alert message="你不是员工" type="error" showIcon />;
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

export default Employer
