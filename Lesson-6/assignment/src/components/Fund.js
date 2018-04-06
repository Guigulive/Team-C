import React, { Component } from 'react'
import { Form, InputNumber, Button } from 'antd';

import Common from './Common';

const FormItem = Form.Item;

class Fund extends Component {
  constructor(props) {
    super(props);

    this.state = {};
  }

  handleSubmit = (ev) => {
    ev.preventDefault();
    const subCommon = this.subCommon;
    const { payroll, account, web3 } = this.props;
    payroll.addFund({
      from: account,
      value: web3.toWei(this.state.fund)
    }).then((result) => {
      if (parseInt(result.receipt.status, 10) === 1) {
        this.setState({
          fund: null,
        });
        alert("增加资金成功！");
      }
    }).catch((error) => {
      console.log(error);
      message.info("你没有足够的余额!");
    });
  }

  render() {
    const { account, payroll, web3 } = this.props;
    return (
      <div>
        <Common account={account} payroll={payroll} web3={web3} ref={(sub)=>{this.subCommon = sub;}} />

        <Form layout="inline" onSubmit={this.handleSubmit}>
          <FormItem>
            <InputNumber
              min={1}
              onChange={fund => this.setState({fund})}
            />
          </FormItem>
          <FormItem>
            <Button
              type="primary"
              htmlType="submit"
              disabled={!this.state.fund}
            >
              增加资金
            </Button>
          </FormItem>
        </Form>
      </div>
    );
  }
}

export default Fund