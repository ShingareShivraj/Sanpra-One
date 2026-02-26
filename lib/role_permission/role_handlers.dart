import 'package:flutter/material.dart';



  class WidgetWithRole extends StatefulWidget {
     const WidgetWithRole({super.key, required this.child});
      final Widget child;
     @override
      State<WidgetWithRole> createState() => _WidgetWithRoleState();
    }

 class _WidgetWithRoleState extends State<WidgetWithRole> {

     // late Core core;


  @override

     void initState() {

       // core = Core();



       super.initState();

      }


     // bool get isAdmin => core.user?.role.name == "admin";



      @override

     Widget build(BuildContext context) {
    // if (isAdmin) {
    //
    //    return widget.child;
    //
    // }



     return Container();

    }

  }