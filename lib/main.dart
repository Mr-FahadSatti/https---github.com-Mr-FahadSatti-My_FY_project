
import 'package:flutter/material.dart';
import 'package:fyp_industrial_watch/api/api.dart';
import 'package:fyp_industrial_watch/model/users.dart';
import 'package:fyp_industrial_watch/screens/ReadingAnalogDisplay/addMeter.dart';
import 'package:fyp_industrial_watch/screens/ReadingAnalogDisplay/meter_test_screen.dart';
import 'package:fyp_industrial_watch/screens/ReadingAnalogDisplay/predict_screen.dart';
import 'package:fyp_industrial_watch/screens/admin/admin_dashboard.dart';
import 'package:fyp_industrial_watch/screens/signin.dart';
import 'package:fyp_industrial_watch/screens/super_admin/dashboard.dart';
import 'package:fyp_industrial_watch/screens/supervisor/supervisor_dashboard.dart';


void main() async{
  // Users u=Users();
  // List<Users> ulist=[];
  // u.email=await u.getemail();
  //  u.password=await u.getpassword();
  // bool isLogin= await u.isLogin();
  //  u.role=await u.getRole();
  //  u.name=await u.getname();
  //  u.id= await u.getid();
  //  u.org_id= await u.getorg_id();
  // ulist.add(u);
  runApp(MaterialApp(
    //home: u.role=='admin'||u.role=='Admin'?AdminDashboard(ulist):u.role=='SuperAdmin'||u.role=='superadmin'?SuperAdminDashboard():u.role=='superviser'|| u.role=='Superviser'?SupervisorDashboard(ulist):u.role=='employee'||u.role=='Employee'?EmployeeData():SignIn(),
    home: SignIn(),
    debugShowCheckedModeBanner: false,
  ));
}


