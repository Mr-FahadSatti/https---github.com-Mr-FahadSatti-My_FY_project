import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fyp_industrial_watch/screens/ReadingAnalogDisplay/predict_screen.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../api/ipaddress.dart';
import '../../customs/customtext.dart';
import '../../customs/custumbutton.dart';
import '../../model/users.dart';
import 'allRecord.dart';
import 'meter_model.dart';
import 'package:http/http.dart' as http;

class Metercreen extends StatefulWidget {
  //const Metercreen({Key? key}) : super(key: key);

  List<Users> ulist=[];
  Metercreen(this.ulist);

  @override
  State<Metercreen> createState() => _MetercreenState();
}

class _MetercreenState extends State<Metercreen> {

  String filterNumbers(String inputString) {
    // Regular expression pattern to match numbers
    RegExp numberPattern = RegExp(r'\d+(\.\d+)?');

    // Extract numbers from the input string
    List<num> numbers = numberPattern
        .allMatches(inputString)
        .map((match) => num.tryParse(match.group(0)!) ?? 0)
        .toList();

    // Join the numbers into a new string
    String filteredString = numbers.join(' ');

    return filteredString;
  }



  bool digita_meter_image=false;
  int? analog_reading;
  String meter_name=" ", date=" ",time=" ";
  bool textscanning=false;
  String scanText=""; String? responce;
  File? img;
  XFile? digital_img;
  XFile? imgfile;
  void getImage(ImageSource source) async{
    try {
      final pickedimage= await ImagePicker().pickImage(source: source);
      if(pickedimage !=null)
      {
        textscanning=true;
        imgfile=pickedimage;
        await getText(pickedimage);
        setState(() {

        });
      }
    }catch(e){
      textscanning=false;
      imgfile =null;
      scanText="Error accoured while scanning";
    }}

  Future<void> getText(XFile image) async
  {
    print("hereeeeeeeeeeeeeeeeeeeeeeee");

    final inputImage= InputImage.fromFilePath(image.path);
    final textDecorator=GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText=await textDecorator.processImage(inputImage);
    await textDecorator.close();
    scanText="";
    for(TextBlock block in recognizedText.blocks)
    {
      for(TextLine line in block.lines)
      {
        scanText=scanText+line.text+" " ;
        meter_reading=filterNumbers(scanText);
        //meter_reading=scanText;
        digita_meter_image=true;
        ///Image.asset(img.toString());
      }
    }
    print("Text : ----------------------"+scanText);
    textscanning=false;
    setState(() {
      date =
      "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
      time = "${DateTime.now().hour}:${DateTime.now().minute}";
      meter_name="digital_meter";

    });

  }

  Meter m=new Meter();
  TextRecognize tr= TextRecognize();
  String? selected;
  String? gval;
  String? meter_reading;
  List<String> itemlist=[];
  List<DropdownMenuItem<String>> getItems() {
    List<DropdownMenuItem<String>> dlist = [];
    itemlist.forEach((element) {
      DropdownMenuItem<String> dropitem = DropdownMenuItem(
          value: element,
          child: Text(element, style: TextStyle(fontSize: 20),)
      );
      dlist.add(dropitem);
    });
    return dlist;
  }

  //XFile? imgfile;
  File? file;
  //String? scanText;

/*

  void getImage(ImageSource source) async{
    try {
      final pickedimage= await ImagePicker().pickImage(source: source);
        imgfile=pickedimage;
        {

          _sendImageToServer();
        setState(() {});
        }
    }catch(e){
      imgfile =null;
      scanText="Error accoured :";
    }}
*/

  //File? img;

  Uint8List? _imageBytes;

  File? meterImage;

  dynamic fileBytes;
  Future<void> _sendImageToServer(ImageSource source) async {
    final picker = ImagePicker();
    final  pickedFile = await picker.pickImage(source: source);
    if(pickedFile!=null)
    {
      setState(() {
        meterImage=File(pickedFile.path);
      });
    }
    fileBytes = await pickedFile!.readAsBytes();
    final request = http.MultipartRequest('GET', Uri.parse('${ip}/getmodel'),);
    final multipartFile = http.MultipartFile.fromBytes(
      'img', fileBytes, filename: 'model.jpg',
    );
    request.fields["type"] = 0.toString();
    request.files.add(multipartFile);
    final response = await request.send();
    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      var data = jsonDecode(result);
      var vol = data['result'];
      print("get_modelResult -------- ${result}");
      print("vol------------------$vol");
      //if(vol=="digital_meter" || vol=="1 digital_meter" || vol=="1 digital_meter " || vol==" 1 digital_meter " || vol==" 1 digital_meter" || vol==" 1 digital_meter, " || vol=="1 digital_meter," || vol=="1 digital_meter " || vol==" 1 digital_meter,"  || vol=="")
      if(vol.contains('digital') || vol=="" || vol == null)
      {
        print("entered here 1111111111111111111111111111");
        vol=="Its digital_meter";
        getText(pickedFile);
        meter_name="digital_meter";
      }
      else{
        print("12345678");
        getAnalogReading();
        setState(() {
          meter_name = vol;
          print("meter name after vol ------------${meter_name}");
        });
      }
    } else {
      throw Exception('Failed to send image');
    }


  }
  Future<void> getAnalogReading() async{
    final request1 = http.MultipartRequest('GET', Uri.parse('${ip}/getmodel2'),);
    final multipartFile1 = http.MultipartFile.fromBytes(
      'img', fileBytes, filename: 'model.jpg',
    );
    print("now checking${meter_name}");
    if(meter_name!=" 1 digital_meter," || meter_name!=" 1 digital_meter, " || meter_name!="1 digital_meter," || meter_name!="1 digital_meter, ")
      request1.fields['label']=meter_name;
    print("now checking again ${meter_name}");
    request1.files.add(multipartFile1);

    final response1 = await request1.send();
    if (response1.statusCode == 200) {
      //CircularProgressIndicator();
      String result = await response1.stream.bytesToString();
      var data = jsonDecode(result);
      print("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq$data");
      var imageString = data['image'];
      var imageB = base64.decode(imageString);
      analog_reading=data['reading'];
      meter_reading=analog_reading.toString();
      setState(() {
        _imageBytes = imageB;
        date =
        "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
        time = "${DateTime.now().hour}:${DateTime.now().minute}";
      });
    } else {
      throw Exception('Failed to send image');
    }
  }
  getImg() {
    if (_imageBytes != null) {
      return Container(
          height: (MediaQuery.of(context).size.height) * 0.35,
          width: (MediaQuery.of(context).size.width) * 0.80,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(_imageBytes!),
              fit: BoxFit.fill,
            ),
          ));
    }
    else if(meter_name.contains("digital") || meter_name.contains(""))
    {
      return meterImage!=null?Container(
          height: (MediaQuery.of(context).size.height) * 0.35,
          width: (MediaQuery.of(context).size.width) * 0.80,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(meterImage!),
              fit: BoxFit.fill,
            ),
          )):Container(
        height: (MediaQuery.of(context).size.height) * 0.25,
        width: (MediaQuery.of(context).size.width) * 0.67,
        color: Colors.grey,
        child: Center(
          child:
          Text("Meter Image",style: TextStyle(fontSize: 30),),
        ),
      );
    }
    {
      return Container(
        height: (MediaQuery.of(context).size.height) * 0.25,
        width: (MediaQuery.of(context).size.width) * 0.67,
        color: Colors.grey,
        child: Center(
          child:
          Text("Meter Image",style: TextStyle(fontSize: 30),),
        ),
      );
    }
  }


  bool flg=false;

  void initState() {
    getMeters();
  }

  Meter mtr=new Meter();
  List<Meter> mlist=[];

  getMeters()async{
    mlist=await mtr.getAllMeter(widget.ulist[0].org_id);
    for(var e in mlist){
      itemlist.add(e.meter_name);
    }
    setState(() {
    });
    print("Length -----------------------"+itemlist.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 0, 53, 103),
        appBar: AppBar(title: Text('Meter Screen'),),
        body:SingleChildScrollView(
          child:
          Padding(
            padding: const EdgeInsets.all(25.0),
            child:
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // if(imgfile== null)
                  //   Container(
                  //   height: 300,
                  //   width: 300,
                  //   child: Image.asset('assets/images/OIP (15).jpg',
                  //   fit: BoxFit.fill,
                  //   ),),
                  // if(imgfile!=null)
                  //   Container(
                  //   height: 270,width: 200,
                  //    child:Image.file(File(imgfile!.path,),fit: BoxFit.fill,),
                  //   ),
                  getImg(),


                  SizedBox(height: 20,),
                  InputDecorator(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.white),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            //canvasColor: Color.fromARGB(255, 119, 235, 253),
                              canvasColor: Colors.black),
                          child: DropdownButton(
                            hint: CustomText("Meter name", Colors.white, 18),
                            value: selected,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            isDense: true,
                            isExpanded: true,
                            items: getItems(),
                            onChanged: (Value) {
                              setState(() {
                                selected = Value!;
                              });
                            },
                          ),
                        )),
                  ),
                  SizedBox(height: 10,),
                  if(selected!=null)
                    Container(
                      height: 70,width: 200,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),child: Column(
                        children: [
                          Text("Unit :  ${mlist.where((element) => element.meter_name==selected).first.meter_unit}",

                            style: TextStyle(fontSize: 30,color: Colors.yellowAccent,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),
                          ),
                          // SizedBox(height: 10,),
                          // Text("Type : ${mlist.where((element) => element.meter_name==selected).first.meter_type}",
                          //   style:TextStyle(fontSize: 25,color: Colors.yellowAccent,),
                          // ),
                        ],
                      ),
                      ),
                    ),

                  // // Container(
                  // //   height: 163,width: 270,
                  // //   child: InputDecorator(
                  // //     decoration: const InputDecoration(
                  // //       border: OutlineInputBorder(),
                  // //       labelText: ("Type"),
                  // //         labelStyle: TextStyle(fontSize: 25,color: Colors.white70),
                  // //     ),
                  // //     child: Column(
                  // //       children: [
                  // //         SizedBox(height: 5,),
                  // //         RadioListTile(
                  // //             title: Text("Analog",style: TextStyle(fontSize: 20,fontWeight: FontWeight.normal,color: Colors.white),),
                  // //             value: 'Analog', groupValue: gval, onChanged: (Object? o){
                  // //               setState(() {
                  // //                 gval=o.toString();
                  // //               });
                  // //         }),
                  // //         SizedBox(height: 5,),
                  // //         RadioListTile(
                  // //             title: Text("Digital",style: TextStyle(fontSize: 20,fontWeight: FontWeight.normal,color: Colors.white),),
                  // //             value: 'Digital', groupValue: gval, onChanged: (Object? o){
                  // //               setState(() {
                  // //                 gval=o.toString();
                  // //               });
                  // //         })
                  // //       ],
                  // //     ),
                  // //   ),
                  // // ),
                  //
                  SizedBox(height: 10,),
                  Container(
                    height: 250,
                    child: Center(
                      child: Container(
                        height: (MediaQuery.of(context).size.height) * 0.35,
                        //width: (MediaQuery.of(context).size.width) * 0.20,
                        child: InputDecorator(
                          decoration:const InputDecoration(
                            enabledBorder:OutlineInputBorder(
                              borderSide:BorderSide(width: 2,color: Colors.white),),),

                          child:
                          Column(
                            children: [
                              SizedBox(height: 16,),
                              Row(
                                children: [
                                  SizedBox(width: 25,),
                                  CustomText("Name :", Color.fromARGB(255, 119, 235, 253), 20),
                                  SizedBox(width: 25,),
                                  CustomText(widget.ulist[0].name, Colors.white, 20)
                                ],
                              ),
                              SizedBox(height: 17,),
                              Row(
                                children: [
                                  SizedBox(width: 25,),
                                  CustomText("Date :", Color.fromARGB(255, 119, 235, 253), 20),
                                  SizedBox(width: 25),
                                  CustomText(date, Colors.white, 20),

                                ],),
                              SizedBox(height: 16,),
                              Row(
                                children: [
                                  SizedBox(width: 25,),
                                  CustomText("Time :", Color.fromARGB(255, 119, 235, 253), 20),
                                  SizedBox(width: 25,),
                                  CustomText(time, Colors.white, 20)

                                ],),
                              SizedBox(height: 16,),
                              Row(
                                children: [
                                  SizedBox(width: 25,),
                                  CustomText("Type : ", Color.fromARGB(255, 119, 235, 253), 20),
                                  SizedBox(width: 25,),
                                  CustomText(meter_name, Colors.white, 20)
                                ],
                              ),
                              SizedBox(height: 17,),
                              Row(
                                children: [
                                  SizedBox(width: 25,),
                                  CustomText("Reading :", Color.fromARGB(255, 119, 235, 253), 18),
                                  SizedBox(width: 20,),
                                  meter_reading!=null?CustomText("${meter_reading}", Colors.red, 20):Center(
                                      child:
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 40,
                                          ),CircularProgressIndicator(color: Colors.white,)
                                        ],
                                      )
                                  )

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),),),
                  SizedBox(height: 10,),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:[
                        CustomButton(()async{
                          _imageBytes=null;
                          meter_reading=null;
                         // date="";time="";
                          _sendImageToServer(ImageSource.gallery);

                        },'Gallary',17,17,17),

                        // SizedBox(width: 10,),
                        // CustomButton(()  async{
                        //   _imageBytes=null;
                        //   meter_reading=null;
                        //   _sendImageToServer(ImageSource.camera);
                        //   setState(() {
                        //
                        //   });
                        // },'Camera',17,17,17),
                        SizedBox(width: 17,),
                        CustomButton(() async{
                        if(selected!=null) {
                          m.emp_id = widget.ulist[0].id;
                          m.id = mlist.where((element) => element.meter_name == selected).first.id;
                          m.reading = meter_reading.toString();
                          m.date = date;
                          m.time = time;
                          //m.m_name = meter_name;
                          //m.meter_unit=mlist.where((element) => element.meter_name==selected).first.meter_unit;
                          responce = await m.MeterAcqusitionMultipart(m);
                          print("Meter Acqusition responce ${responce}");
                          setState(() {

                          });
                        }
                        else
                          {
                            Fluttertoast.showToast(
                                msg: "Select meter name to save data",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                textColor: Colors.red,
                                fontSize: 20.0);
                          }

                        }, "Save", 17, 17, 17)
                      ]),
                  SizedBox(height:10),
                  CustomButton((){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>My_meter_data(widget.ulist),));
                  },'Show All',17,15,15),

                ]
            ),),)
    );
  }
}
