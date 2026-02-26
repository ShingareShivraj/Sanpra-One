import 'package:stacked/stacked.dart';

import '../../../model/project_lead_model.dart';
import '../../../services/add_project_lead_services.dart';

class ProjectLeadListViewModel extends BaseViewModel {
  final _service = ProjectLeadService();

  List<ProjectLead> leads = [];

  Future<void> fetchLeads() async {
    setBusy(true);

    leads = await _service.getAllProjectLead();
    notifyListeners();
    setBusy(false);
  }
}
