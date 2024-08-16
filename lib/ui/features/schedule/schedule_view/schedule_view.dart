import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:telehealth_app/ui/features/schedule/schedule_controller/schedule_controller.dart';
import 'package:telehealth_app/ui/shared/custom_appbar.dart';
import 'package:telehealth_app/ui/shared/global_variables.dart';
import 'package:telehealth_app/ui/shared/spacer.dart';
import 'package:telehealth_app/utils/app_constants/app_colors.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  final ScheduleController controller = Get.put(ScheduleController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 50),
          child: const CustomAppbar(
            title: "Medical Records",
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Full Name', controller.fullNameController),
                CustomSpacer(20),
                _buildTextField('Gender', controller.genderController),
                CustomSpacer(20),
                _buildTextField('Contact Info', controller.contactInfoController),
                CustomSpacer(20),
                _buildTextField('EmergencyContact', controller.emergencyContact),
                CustomSpacer(20),
                _buildTextField('Date of Birth', controller.dobController),
                CustomSpacer(20),
                _buildTextField('Allergic Substance', controller.allergicSubstanceController),
                CustomSpacer(20),
                _buildTextField('Reaction Type', controller.reactionTypeController),
                CustomSpacer(20),
                _buildTextField('Severity', controller.severityController),
                CustomSpacer(20),
                ElevatedButton(
                  onPressed: () {
                  controller.saveMedicalRecord();
                  print('Role....: ${GlobalVariables.myRole}');
                  print('Password....: ${GlobalVariables.myPassword}');
                  print('Username....: ${GlobalVariables.myUsername}');
                  },
                  child: const Center(
                    child: Text('Save Record'),
                  ),
                ),
                CustomSpacer(20),
                // Obx(() {
                //   if (controller.records.isEmpty) {
                //     return const Center(child: Text("No records available."));
                //   } else {
                //     return ListView.builder(
                //       shrinkWrap: true,
                //       physics: const NeverScrollableScrollPhysics(),
                //       itemCount: controller.records.length,
                //       itemBuilder: (context, index) {
                //         final record = controller.records[index];
                //         return Card(
                //           margin: const EdgeInsets.symmetric(vertical: 10),
                //           child: Padding(
                //             padding: const EdgeInsets.all(10.0),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text(
                //                   '${record.gender} ${record.contactInfo} ${record.fullName}',
                //                   style: const TextStyle(
                //                     fontSize: 18,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 ),
                //                 CustomSpacer(10),
                //                 Text("EmergencyContact: ${record.emergencyContact}"),
                //                 CustomSpacer(10),
                //                 Text("Date of Birth: ${record.dob}"),
                //                 CustomSpacer(10),
                //                 CustomSpacer(10),
                //                 Text("Allergic Substance: ${record.allergicSubstance}"),
                //                 CustomSpacer(10),
                //                 Text("Reaction Type: ${record.reactionType}"),
                //                 CustomSpacer(10),
                //                 Text("Severity: ${record.severity}"),
                //                 CustomSpacer(10),
                //               ],
                //             ),
                //           ),
                //         );
                //       },
                //     );
                //   }
                // }),
                CustomSpacer(100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      label,
      style: TextStyle(
        color: AppColors.darkGray,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    CustomSpacer(10),
    Container(
    decoration: BoxDecoration(
    color: AppColors.lightGray,
      borderRadius: BorderRadius.circular(8.0),
    ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        ),
        keyboardType: TextInputType.text,
      ),
    ),
      ],
    );
  }
}

