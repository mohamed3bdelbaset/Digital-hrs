import 'dart:convert';

import 'package:cnattendance/data/source/datastore/preferences.dart';
import 'package:cnattendance/data/source/network/model/projectdashboard/ProjectDashboardResponse.dart';
import 'package:cnattendance/model/member.dart';
import 'package:cnattendance/model/project.dart';
import 'package:cnattendance/model/task.dart';
import 'package:cnattendance/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProjectDashboardController extends GetxController {
  var overview = {
    "progress": 0,
    "total_project": 0,
    "project_completed": 0,
  }.obs;

  var taskList = [].obs;
  var projectList = [].obs;

  Future<String> getProjectOverview() async {
    Preferences preferences = Preferences();
    var uri = Uri.parse(await preferences.getAppUrl() +
        Constant.PROJECT_DASHBOARD_URL +
        "?tasks=10&projects=3");

    String token = await preferences.getToken();

    Map<String, String> headers = {
      'Accept': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    };

    final response = await http.get(
      uri,
      headers: headers,
    );
    debugPrint(response.body.toString());

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final projectResponse = ProjectDashboardResponse.fromJson(responseData);

      taskList.clear();
      projectList.clear();

      overview['progress'] =
          projectResponse.data.progressProject.progress_in_percent;
      overview['total_project'] =
          projectResponse.data.progressProject.total_project_assigned;
      overview['project_completed'] =
          projectResponse.data.progressProject.total_project_completed;

      overview.refresh();

      for (var task in projectResponse.data.assigned_task) {
        DateFormat("MMM dd yyyy", "en").parse(task.start_date);
        DateFormat("MMM dd yyyy", "en").parse(task.end_date);

        List<Member> taskMembers = [];

        for (var member in task.assigned_member) {
          taskMembers.add(Member(member.id, member.name, member.avatar));
        }

        taskList.add(Task(task.task_id, task.task_name, task.project_name,
            task.start_date, task.end_date, task.status,
            members: taskMembers, priority: task.priority));
      }

      List<Member> members = [];
      for (var project in projectResponse.data.projects) {
        for (var member in project.assigned_member) {
          members.add(Member(member.id, member.name, member.avatar));
        }

        DateFormat("MMM dd yyyy", "en").parse(project.start_date);

        projectList.add(Project(
            project.id,
            project.project_name,
            project.slug,
            "",
            project.start_date,
            project.priority,
            project.status,
            project.project_progress_percent,
            project.assigned_task_count,
            members, [], []));
      }

      return "Loaded";
    } else {
      var errorMessage = responseData['message'];
      print(errorMessage);
      throw errorMessage;
    }
  }

  @override
  void onReady() {
    getProjectOverview();
    super.onReady();
  }
}
