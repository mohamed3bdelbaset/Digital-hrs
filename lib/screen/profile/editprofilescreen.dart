import 'dart:io';

import 'package:cnattendance/widget/buttonborder.dart';
import 'package:cnattendance/widget/radialDecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:cnattendance/provider/profileprovider.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/editprofile';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  int genderIndex = 0;
  bool isLoading = false;

  final _form = GlobalKey<FormState>();

  late ScrollController scrollController;

  bool initial = true;

  bool validateField(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(hideKeyboard);
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  String getGender() {
    switch (genderIndex) {
      case 0:
        return 'male';
      case 1:
        return 'female';
      case 2:
        return 'others';
      default:
        return 'male';
    }
  }

  void setLoading(bool value) {
    if (!mounted) return;

    setState(() {
      isLoading = value;
    });
  }

  Future<void> validateValue() async {
    if (isLoading) return;

    FocusScope.of(context).unfocus();

    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }

    setLoading(true);
    EasyLoading.show(
      status: 'Changing',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final response =
          await Provider.of<ProfileProvider>(context, listen: false)
              .updateProfile(
        _nameController.text,
        _emailController.text,
        _addressController.text,
        _dobController.text,
        getGender(),
        _phoneController.text,
        File(''),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );

        setLoading(false);
        EasyLoading.dismiss(animation: true);

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      EasyLoading.dismiss(animation: true);
      setLoading(false);
    }
  }

  Future<void> changeAvatar(ProfileProvider provider) async {
    if (isLoading) return;

    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 500,
      );

      if (image == null || !mounted) return;

      setLoading(true);

      EasyLoading.show(
        status: 'Changing....',
        maskType: EasyLoadingMaskType.black,
      );

      await provider.updateProfile(
        '',
        '',
        '',
        '',
        '',
        '',
        File(image.path),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      EasyLoading.dismiss(animation: true);
      setLoading(false);
    }
  }

  Future<void> selectDate() async {
    FocusScope.of(context).unfocus();

    // final DateTime now = DateTime.now();

    DateTime initialDate = DateTime(2000);

    if (_dobController.text.isNotEmpty) {
      final parsedDate = DateTime.tryParse(_dobController.text);

      if (parsedDate != null) {
        initialDate = parsedDate;
      }
    }

    if (initialDate.isBefore(DateTime(1950))) {
      initialDate = DateTime(1950);
    }

    if (initialDate.isAfter(DateTime(2100))) {
      initialDate = DateTime(2100);
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (initial) {
      final profile =
          Provider.of<ProfileProvider>(context, listen: false).profile;

      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _addressController.text = profile.address;
      _phoneController.text = profile.phone;
      _dobController.text = profile.dob;

      switch (profile.gender.toLowerCase()) {
        case 'male':
          genderIndex = 0;
          break;
        case 'female':
          genderIndex = 1;
          break;
        case 'others':
          genderIndex = 2;
          break;
        default:
          genderIndex = 0;
          break;
      }

      initial = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    final profile = provider.profile;

    return PopScope(
      canPop: !isLoading,
      child: Container(
        decoration: RadialDecoration(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              translate('edit_profile_screen.edit_profile'),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(20),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xff036eb7),
                shape: ButtonBorder(),
                fixedSize: const Size(double.maxFinite, 55),
              ),
              onPressed: isLoading ? null : validateValue,
              child: Text(
                translate('edit_profile_screen.update'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          body: Form(
            key: _form,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: isLoading ? null : () => changeAvatar(provider),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            image: profile.avatar.isNotEmpty
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(profile.avatar),
                                  )
                                : null,
                            color: Colors.white12,
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            color: Colors.black12,
                            padding: const EdgeInsets.all(20),
                            child: const Text(
                              'Change',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Name
                    buildTextField(
                      controller: _nameController,
                      hint: translate('edit_profile_screen.fullname'),
                      icon: Icons.person,
                      keyboardType: TextInputType.name,
                    ),

                    const SizedBox(height: 10),

                    // Email
                    buildTextField(
                      controller: _emailController,
                      hint: translate('edit_profile_screen.email'),
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 10),

                    // Address
                    buildTextField(
                      controller: _addressController,
                      hint: translate('edit_profile_screen.address'),
                      icon: Icons.location_on,
                      keyboardType: TextInputType.streetAddress,
                    ),

                    const SizedBox(height: 10),

                    // Phone
                    buildTextField(
                      controller: _phoneController,
                      hint: translate('edit_profile_screen.phone_number'),
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 10),

                    // Date of birth
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: isLoading ? null : selectDate,
                      validator: (value) {
                        if (!validateField(value)) {
                          return 'Empty Field';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.datetime,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: inputDecoration(
                        translate('edit_profile_screen.dob'),
                        Icons.calendar_month_sharp,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translate('edit_profile_screen.gender'),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ToggleSwitch(
                            borderWidth: 1,
                            borderColor: [Colors.white12],
                            dividerColor: Colors.white12,
                            activeBgColor: const [Colors.white12],
                            activeFgColor: Colors.white,
                            inactiveFgColor: Colors.white,
                            inactiveBgColor: Colors.transparent,
                            minWidth: 100,
                            minHeight: 45,
                            initialLabelIndex: genderIndex,
                            totalSwitches: 3,
                            onToggle: (index) {
                              if (index != null && !isLoading) {
                                setState(() {
                                  genderIndex = index;
                                });
                              }
                            },
                            labels: [
                              translate('edit_profile_screen.male'),
                              translate('edit_profile_screen.female'),
                              translate('edit_profile_screen.other'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (!validateField(value)) {
          return 'Empty Field';
        }
        return null;
      },
      cursorColor: Colors.white,
      decoration: inputDecoration(hint, icon),
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      labelStyle: const TextStyle(color: Colors.white),
      fillColor: Colors.white24,
      filled: true,
      enabledBorder: outlineBorder(),
      focusedBorder: outlineBorder(),
      focusedErrorBorder: outlineBorder(),
      errorBorder: outlineBorder(),
    );
  }

  OutlineInputBorder outlineBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(10),
      ),
    );
  }
}
