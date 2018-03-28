import React, { Component } from 'react'
import { Table, Button, Modal, Form, InputNumber, Input, message, Popconfirm } from 'antd';

import EditableCell from './EditableCell';

const FormItem = Form.Item;

const columns = [{
  title: '地址',
  dataIndex: 'address',
  key: 'address',
}, {
  title: '薪水',
  dataIndex: 'salary',
  key: 'salary',
}, {
  title: '上次支付',
  dataIndex: 'lastPaidDay',
  key: 'lastPaidDay',
}, {
  title: '操作',
  dataIndex: '',
  key: 'action'
}];

class EmployeeList extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      employees: [],
      showModal: false
    };

    columns[1].render = (text, record) => (
      <EditableCell
        value={text}
        onChange={ this.updateEmployee.bind(this, record.address) }
      />
    );

    columns[3].render = (text, record) => (
      <Popconfirm title="你确定删除吗?" onConfirm={
        () => this.removeEmployee(record.address)}>
        <a href="#">Delete</a>
      </Popconfirm>
    );
  }

  componentDidMount() {
    const { payroll, account, web3 } = this.props;
    payroll.checkInfo.call({
      from: account
    }).then((result) => {
      const employeeCount = result[2].toNumber();

      if (employeeCount === 0) {
        this.setState({loading: false});
        return;
      }

      this.loadEmployees(employeeCount);
    });

  }

  loadEmployees(employeeCount) {
    const { payroll, account, web3 } = this.props;
    var requests = [];

    for (var i = 0; i < employeeCount; i++) {
      requests.push(payroll.checkEmployee.call(i), {from: account});
    }

    Promise.all(requests)
    .then(values => {
      const employees = values.filter(value => Array.isArray(value))
      .map(value => ({
        key: value[0],
        address: value[0],
        salary: web3.fromWei(value[1].toNumber()),
        lastPaidDay: Date(value[2].toNumber() * 1000),
        action: '删除',
      }));

      this.setState({
        employees,
        loading: false,
      });
    });  
  }

  addEmployee = () => {
    const { payroll, account, web3 } = this.props;
    payroll.addEmployee(this.state.address, this.state.salary, {
      from: account,
      gas: 5000000,
    })
    .then(() => {alert('add employee succssful! Refresh to see change')})
    .catch((err) => {
      console.log('failed!\n' + err);
    });
  }

  updateEmployee = (address, salary) => {
    const { payroll, account, web3 } = this.props;
    payroll.updateEmployee(address, salary, {
      from: account,
      gas: 5000000,
    })
    .then(() => {
      let nextEmployees = this.state.employees;
      for (let i = 0; i < nextEmployees.length; i++) {
        if (nextEmployees[i].address === address) {
          nextEmployees[i].salary = salary;
        }
      }
      this.setState({employees: nextEmployees});
    })
    .catch((err) => {
      console.log('fail to update, err: ' + err);
    });
  }

  removeEmployee = (employeeId) => {
    const { payroll, account, web3 } = this.props;
    payroll.removeEmployee(employeeId, {
      from: account,
      gas: 5000000,
    })
    .then(() => {
      let nextEmployees = this.state.employees;
      for (let i = 0; i < nextEmployees.length; i++) {
        if (nextEmployees[i].address === employeeId) {
          nextEmployees.splice(i, 1);
        }
      }
      this.setState({employees: nextEmployees});
    })
    .catch((err) => {
      console.log('fail to delete, err: ' + err);
    });
  }

  renderModal() {
      return (
      <Modal
          title="增加员工"
          visible={this.state.showModal}
          onOk={this.addEmployee}
          onCancel={() => this.setState({showModal: false})}
      >
        <Form>
          <FormItem label="地址">
            <Input
              onChange={ev => this.setState({address: ev.target.value})}
            />
          </FormItem>

          <FormItem label="薪水">
            <InputNumber
              min={1}
              onChange={salary => this.setState({salary})}
            />
          </FormItem>
        </Form>
      </Modal>
    );

  }

  render() {
    return (
      <div>
        <Button
          type="primary"
          onClick={() => this.setState({showModal: true})}
        >
          增加员工
        </Button>

        {this.renderModal()}

        <Table
          loading={this.state.loading}
          dataSource={this.state.employees}
          columns={columns}
        />
      </div>
    );
  }
}

export default EmployeeList
