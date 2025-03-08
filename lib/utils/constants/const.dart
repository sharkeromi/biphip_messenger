import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const double kButtonHeight = 44.0;
const double kTextfieldHeight = 52.0;
const double kCommonBackSpace = 50.0;
const double kBottomNavHeight = 44.0;

const double k4BorderRadius = 4.0;
const double k8BorderRadius = 8.0;
const double k12BorderRadius = 12.0;
const double k16BorderRadius = 16.0;
const double k20BorderRadius = 20.0;

BorderRadius k4CircularBorderRadius = BorderRadius.circular(4.0);
BorderRadius k8CircularBorderRadius = BorderRadius.circular(8.0);
BorderRadius k12CircularBorderRadius = BorderRadius.circular(12.0);
BorderRadius k16CircularBorderRadius = BorderRadius.circular(16.0);
BorderRadius k20CircularBorderRadius = BorderRadius.circular(20.0);
BorderRadius k100CircularBorderRadius = BorderRadius.circular(100.0);

const double kAppBarSize = 44.0;
const double kAppBarSizeSetting = 60;
const int kMinPasswordLength = 8;
const int kOTPLength = 4;

//* Icon sizes
const double kIconSize8 = 8.0;
const double kIconSize12 = 12.0;
const double kIconSize16 = 16.0;
const double kIconSize20 = 20.0;
const double kIconSize24 = 24.0;
const double kIconSize28 = 28.0;

const double kIconSize14 = 14.0;
const double kIconSize18 = 18.0;
const double kIconSize22 = 22.0;
const double kIconSize25 = 25.0;
const double kIconSize30 = 30.0;
const double kIconSize35 = 35.0;
const double kIconSize40 = 40.0;
const double kIconSize45 = 45.0;
const double kIconSize50 = 50.0;
const double kIconSize60 = 60.0;
const double kIconSize70 = 70.0;
const double kIconSize100 = 100.0;
const double kIconSize150 = 150.0;
const double kIconSize120 = 120.0;
const double kIconSize200 = 200.0;

//* size limit comparison constant
const double kSmallDeviceSizeLimit = 750.0;

//* elevation for different component
const double kCommonElevation = 0.0;

//* padding for different component
const double kHorizontalPadding = 20.0;
const double k0Padding = 0.0;
const double k2Padding = 2.0;
const double k4Padding = 4.0;
const double k8Padding = 8.0;
const double k10Padding = 10.0;
const double k12Padding = 12.0;
const double k16Padding = 16.0;
const double k20Padding = 20.0;
const double k24Padding = 24.0;
const double k25Padding = 25.0;
const double k28Padding = 28.0;
const double k30Padding = 30.0;
const double k40Padding = 40.0;
const double k48Padding = 48.0;
const double k50Padding = 50.0;
const double k60Padding = 60.0;
const double k100Padding = 100.0;
const double k120Padding = 120.0;
const double k140Padding = 140.0;

//* empty sized box with only width
const kEmptySizedBox = SizedBox();
const kW4sizedBox = SizedBox(width: k4Padding);
const kW8sizedBox = SizedBox(width: k8Padding);
const kW12sizedBox = SizedBox(width: k12Padding);
const kW16sizedBox = SizedBox(width: k16Padding);
const kW20sizedBox = SizedBox(width: k20Padding);
const kW24sizedBox = SizedBox(width: k24Padding);
const kW25sizedBox = SizedBox(width: k25Padding);
const kW30sizedBox = SizedBox(width: k30Padding);
const kW40sizedBox = SizedBox(width: k40Padding);
const kW50sizedBox = SizedBox(width: k50Padding);
const kW60sizedBox = SizedBox(width: k60Padding);
const kW100sizedBox = SizedBox(width: k100Padding);

//* empty sized box with only height
const kH4sizedBox = SizedBox(height: k4Padding);
const kH8sizedBox = SizedBox(height: k8Padding);
const kH12sizedBox = SizedBox(height: k12Padding);
const kH16sizedBox = SizedBox(height: k16Padding);
const kH20sizedBox = SizedBox(height: k20Padding);
const kH24sizedBox = SizedBox(height: k24Padding);
const kH28sizedBox = SizedBox(height: k28Padding);
const kH10sizedBox = SizedBox(height: k10Padding);
const kH25sizedBox = SizedBox(height: k25Padding);
const kH30sizedBox = SizedBox(height: k30Padding);
const kH35sizedBox = SizedBox(height: k30Padding);
const kH40sizedBox = SizedBox(height: k40Padding);
const kH48sizedBox = SizedBox(height: k48Padding);
const kH50sizedBox = SizedBox(height: k50Padding);
const kH60sizedBox = SizedBox(height: k60Padding);
const kH100sizedBox = SizedBox(height: k100Padding);
const kHBottomSizedBox = SizedBox(height: k40Padding);

//* begin:: font sizes

const double h60 = 60.0;
const double h50 = 50.0;
const double h45 = 45.0;
const double h44 = 44.0;
const double h40 = 40.0;
const double h42 = 42.0;
const double h36 = 36.0;
const double h32 = 32.0;
const double h28 = 28.0;
const double h24 = 24.0;
const double h20 = 20.0;
const double h16 = 16.0;
const double h14 = 14.0;
const double h12 = 12.0;
const double h8 = 8.0;

const double h26 = 26.0;
const double h18 = 18.0;
const double h10 = 10.0;
const double h134 = 134.0;

//* end:: font sizes

//* device height and width
double height = 0.0;
double width = 0.0;
double keyboardValue = 0.0;

const double kProfileImageSize = 150;

var formatter = NumberFormat.decimalPattern('en_US');

List profession = [
  'Farmer',
  'UI/UX Designer',
  'Programmer',
  'Product Designer',
  'Cobbler',
  'Tailor',
  'Biker',
  'Photographer',
  'Artist',
  'Singer',
  'Content Writer',
  'Others'
];

List interest = [
  'Poetry',
  'Photography',
  'Singing',
  'Writing',
  'Painting',
  'Kid',
  'Story telling',
];

List genders = ['Male', 'Female', 'Others'];

const String kPost = "POST";
const String kGet = "GET";
const String kDelete = "DELETE";
const String kPut = "PUT";
const String kPatch = "PATCH";
