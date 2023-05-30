// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../model/users.dart';
import 'meter_model.dart';

// ignore: camel_case_types, must_be_immutable
class My_meter_data extends StatefulWidget {
  List<Users> ulist = [];
  My_meter_data(this.ulist);
  @override
  _My_meter_dataState createState() => _My_meter_dataState();
}

class _My_meter_dataState extends State<My_meter_data> {
  List<Meter> mlist = [];

  //late int uid;

  Meter m = Meter();

  @override
  void initState() {
    super.initState();
    //m.Get_data_for_supervisor(widget.ulist[0].id);
    //setState(() {

    //});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meter Detail'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Meter>>(
        future: m.Get_data_for_supervisor(widget.ulist[0].id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            mlist=snapshot.data!;
            List<DataRow> rows = [];
            for (int i = 0; i < mlist.length; i++) {
              rows.add(DataRow(cells: [
                DataCell(Text(mlist[i].emp_name!)),
                DataCell(Text(mlist[i].meter_name!)),
                DataCell(Text(mlist[i].meter_unit!)),
                DataCell(Text(mlist[i].reading!)),
                DataCell(Text(mlist[i].date!)),
                DataCell(Text(mlist[i].time!)),
              ]));
          }
            mlist = snapshot.data!;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Worker Name')),
                  DataColumn(label: Text('Meter Name')),
                  DataColumn(label: Text('Meter Unit')),
                  DataColumn(label: Text('Reading')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Time')),

                ],
                rows: rows
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}