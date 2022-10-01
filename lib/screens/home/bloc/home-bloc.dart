import 'package:material_kit_flutter/screens/home/models/check-in.dart';

class HomeBloc {
  CheckInModel checkInModel = CheckInModel();
  
  HomeBloc();
  
  /// false -> untuk checkin, true -> untuk checkout, nilai berubah sesuai dengan response API
  // bool statusAbsensi() { 
  //   if(status.checkInTime == '' && status.checkInImg == '') {
  //     return false;
  //   }
  //   return status.checkOutTime == '' && status.checkOutImg == '';
  // }
}