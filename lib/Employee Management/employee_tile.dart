import 'package:flutter/material.dart';
import 'package:mobile_app/Employee%20Management/EmployeeDetails.dart';
import 'package:mobile_app/Employee%20Management/Employees.dart';
import 'package:mobile_app/Employee%20Management/addEmployee.dart';
import 'package:mobile_app/Employee%20Management/updateEmployee.dart';
import 'package:mobile_app/services/Service%20Employe/GestionEmployeService.dart';
import 'package:mobile_app/services/projectMnagementService/project_mangementService.dart';

class EmployeeDirectoryPage extends StatefulWidget {
  @override
  _EmployeeDirectoryPageState createState() => _EmployeeDirectoryPageState();
}

class _EmployeeDirectoryPageState extends State<EmployeeDirectoryPage> {
  final GestionEmployeService _employeeService = GestionEmployeService();
  final ProjectManagementService _projectService = ProjectManagementService();
  final int itemsPerPage = 10;
  int currentPage = 1;
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(() {
      filterEmployeesByName(searchController.text);
    });
    fetchEmployees();
  }

  void fetchEmployees() async {
    try {
      List<Employee> fetchedEmployees =
          (await _employeeService.fetchAllEmployees()).map((data) {
        return Employee.fromMap(data, data['id']);
      }).toList();
      setState(() {
        employees = fetchedEmployees;
        filteredEmployees = fetchedEmployees;
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  void filterEmployeesByName(String query) {
    final queryLower = query.toLowerCase();
    setState(() {
      filteredEmployees = employees.where((employee) {
        return employee.name.toLowerCase().contains(queryLower);
      }).toList();
    });
  }

  List<Employee> get paginatedFilteredEmployees {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    endIndex = endIndex > filteredEmployees.length
        ? filteredEmployees.length
        : endIndex;
    return filteredEmployees.sublist(startIndex, endIndex);
  }

  void goToNextPage() {
    if ((currentPage * itemsPerPage) < filteredEmployees.length) {
      setState(() {
        currentPage++;
      });
    }
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  void onDelete(String employeeId) async {
    try {
      await _employeeService.deleteEmployee(employeeId);
      fetchEmployees();
    } catch (e) {
      print('Error deleting employee: $e');
    }
  }

  @override
  void dispose() {
    searchController.removeListener(() {
      filterEmployeesByName(searchController.text);
    });
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9155FD), Color(0xFFC5A5FE)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Image.asset('assets/smartovate.png', height: 50),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: searchController,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search (Ctrl+/)',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.white, size: 20),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (text) {
                    filterEmployeesByName(text);
                  },
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Employees',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddEmployeeScreen()),
                  ).then((_) => fetchEmployees());
                },
                child: Text('ADD EMPLOYEE'),
              ),
              Image.asset('assets/SEO.png'),
              Container(
                color: Color(0xFF28243D),
                child: Column(
                  children: [
                    EmployeeHeader(),
                    ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: paginatedFilteredEmployees.length,
                      itemBuilder: (context, index) {
                        return EmployeeRow(
                          employee: paginatedFilteredEmployees[index],
                          onDelete: onDelete,
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: goToPreviousPage,
                          tooltip: 'Previous page',
                        ),
                        Text('Page $currentPage'),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          onPressed: goToNextPage,
                          tooltip: 'Next page',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmployeeRow extends StatelessWidget {
  final Employee employee;
  final Function(String) onDelete;

  EmployeeRow({required this.employee, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFAD81FE),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            width: 100,
            alignment: Alignment.center,
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                employee.imagePath.isEmpty
                    ? 'assets/Ellipse 10.png'
                    : employee.imagePath,
              ),
              radius: 40,
            ),
          ),
          Container(
            width: 150,
            alignment: Alignment.center,
            child: Text(employee.name, style: TextStyle(color: Colors.white)),
          ),
          Container(
            width: 200,
            alignment: Alignment.center,
            child: Text(employee.email, style: TextStyle(color: Colors.white)),
          ),
          Container(
            width: 150,
            alignment: Alignment.center,
            child:
                Text(employee.jobTitle, style: TextStyle(color: Colors.white)),
          ),
          Container(
            width: 120,
            alignment: Alignment.center,
            child: Text(employee.phoneNumber,
                style: TextStyle(color: Colors.white)),
          ),
          Container(
            width: 100,
            alignment: Alignment.center,
            child:
                Text(employee.country, style: TextStyle(color: Colors.white)),
          ),
          Container(
            width: 60,
            alignment: Alignment.center,
            child: CustomPopupMenuButton(
              onSelected: (String value) {
                _handleMenuItemSelected(context, value);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'View':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailsPage(employee: employee),
          ),
        );
        break;
      case 'Edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateEmployeePage(employee: employee),
          ),
        );
        break;
      case 'Delete':
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm Delete"),
              content: Text("Are you sure you want to delete this employee?"),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text("Delete"),
                  onPressed: () {
                    onDelete(employee.id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        break;
      default:
        break;
    }
  }
}

class EmployeeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      color: Color(0xFF28243D),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Text('Name', style: TextStyle(color: Colors.white))),
          Expanded(child: Text('Email', style: TextStyle(color: Colors.white))),
          Expanded(
              child: Text('Job Title', style: TextStyle(color: Colors.white))),
          Expanded(
              child:
                  Text('Phone Number', style: TextStyle(color: Colors.white))),
          Expanded(
              child: Text('Country', style: TextStyle(color: Colors.white))),
          Expanded(
              child: Text('Actions', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

typedef MenuItemCallback = void Function(String value);

class CustomPopupMenuButton extends StatelessWidget {
  final MenuItemCallback onSelected;

  CustomPopupMenuButton({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.more_vert, color: Colors.white),
      onPressed: () {
        _showCustomMenu(context);
      },
    );
  }

  void _showCustomMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        _buildPopupMenuItem(context, 'View', Icons.visibility),
        _buildPopupMenuItem(context, 'Edit', Icons.edit),
        _buildPopupMenuItem(context, 'Delete', Icons.delete),
      ],
      color: Color(0xFF28243D),
    ).then((value) {
      if (value != null) {
        onSelected(value);
      }
    });
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      BuildContext context, String value, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(value, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
