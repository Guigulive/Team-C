import React, { Component } from 'react';
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
        onChange={ this.updateEmployee.bind(this, record.address) } />
    );

    columns[3].render = (text, record) => (
      <Popconfirm title="你确定删除吗?" onConfirm={() => this.removeEmployee(record.address)}>
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
    const { account, payroll, web3 } = this.props;
    const request = [];

    for (var i = 0; i < employeeCount; i++) {
      request.push(payroll.checkEmployee.call(i, {from: account, gas: 310000}));
    }

    Promise.all(request)
    .then((values) =>{
      const employees = values.map(value => ({
        key: value[0],
        address: value[0],
        salary: web3.fromWei(value[1].toNumber()),
        lastPaidDay: new Date(value[2].toNumber() * 1000).toString()
      }));

      this.setState({
         employees,
         loading: false
      })
    });


  }

  addEmployee = () => {
    const { account, payroll } = this.props;
    payroll.addEmployee(this.state.address, this.state.salary, {
      from: account,
      gas: 310000
    }).then(() =>{
      const newEmployee = {
        key: this.state.address,
        address: this.state.address,
        salary: this.state.salary,
        lastPaidDay: new Date().toString()
      };

      this.setState({
        address: '',
        salary: '',
        employees: this.state.employees.concat([newEmployee]),
        showModal: false
      });

    });
  }

  updateEmployee = (address, salary) => {
    const { account, payroll } = this.props;
    const { employees } = this.state;

    payroll.updateEmployee(address, salary, {
      from: account,
      gas: 310000
    }).then(() =>{
      this.setState({
        employees: employees.map((employee) => {
          if(employee.address === this.state.address){
            employee.salary = salary;
          }

          return employee;
        }),
        showModal: false
      });
    }).catch(err =>{
      message.error('你没有足够的余额');
    });
  }

  removeEmployee = (employeeId) => {
    const { account, payroll } = this.props;
    payroll.removeEmployee(employeeId, {
      from: account,
      gas: 310000
    }).then(() =>{
      this.setState({
        employees: this.state.employees.filter(employee => employee.address !== employeeId),
        showModal: false
      });
    }).catch(() =>{
      message.error('你没有足够的余额');
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
    const { loading, employees } = this.state;
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
          loading={loading}
          dataSource={employees}
          columns={columns}
        />
      </div>
    );
  }
}

export default EmployeeList
