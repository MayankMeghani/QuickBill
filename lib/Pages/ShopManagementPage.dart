import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Providers/ShopProvider.dart';
import '../api/Authenticator.dart';

class ShopManagementPage extends StatefulWidget {
  @override
  _ShopManagementPageState createState() => _ShopManagementPageState();
}

class _ShopManagementPageState extends State<ShopManagementPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _shopData;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isBiometricEnabled= false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstNoController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _gstNoController.dispose();
    _ownerNameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadShopData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = _auth.currentUser!.uid;
      DocumentSnapshot shopDoc =
          await _firestore.collection('shops').doc(userId).get();

      if (shopDoc.exists) {
        setState(() {
          _shopData = shopDoc.data() as Map<String, dynamic>;
          _isBiometricEnabled = prefs.getBool('isBiometricEnabled')!;
          _isLoading = false;
        });
        _updateControllers();
      } else {
        setState(() {
          _shopData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading shop data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateControllers() {
    _nameController.text = _shopData?['name'] ?? '';
    _addressController.text = _shopData?['address'] ?? '';
    _gstNoController.text = _shopData?['gstNo'] ?? '';
    _ownerNameController.text = _shopData?['ownerName'] ?? '';
    _mobileNumberController.text = _shopData?['mobileNo'] ?? '';
  }

  Future<void> _saveShopData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String userId = _auth.currentUser!.uid;
        await _firestore.collection('shops').doc(userId).set({
          'name': _nameController.text,
          'address': _addressController.text,
          'gstNo': _gstNoController.text,
          'ownerName': _ownerNameController.text,
          'mobileNo': _mobileNumberController.text,
          'isProfileComplete': true,
        }, SetOptions(merge: true));

        await context.read<ShopProvider>().loadShopData(_auth.currentUser?.email);

        await _loadShopData();
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        print('Error saving shop data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save shop data. Please try again.')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _toggleBiometric(bool value) async {
    if (value) {
        bool Authenticate =await _authService.authenticateWithBiometrics();

        if (Authenticate) {
          setState(() {
            _isBiometricEnabled = true;
            _authService.saveCredentials();
          });
        }
        else{
          setState(() {
            _isBiometricEnabled = false;
            _authService.removeCredentials();
          });
        }
    } else {
      setState(() {
        _isBiometricEnabled = false;
        _authService.removeCredentials();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _shopData == null ||
                    _shopData!['isProfileComplete'] == false ||
                    _isEditing
                ? _buildShopForm()
                : _buildShopDetails(),
      ),
    );
  }

  Widget _buildShopDetails() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shop Details', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16),
          Text('Shop Name: ${_shopData!['name'] ?? 'Not set'}'),
          SizedBox(height: 8),
          Text('Address: ${_shopData!['address'] ?? 'Not set'}'),
          SizedBox(height: 8),
          Text('GST No: ${_shopData!['gstNo'] ?? 'Not set'}'),
          SizedBox(height: 8),
          Text('Owner Name: ${_shopData!['ownerName'] ?? 'Not set'}'),
          SizedBox(height: 8),
          Text('Mobile No: ${_shopData!['mobileNo'] ?? 'Not set'}'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            child: Text('Edit Profile'),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enable Biometric Authentication'),
              Switch(
                value: _isBiometricEnabled,
                onChanged: (value) async {
                  await _toggleBiometric(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _shopData == null || _shopData!['isProfileComplete'] == false
                  ? 'Complete Your Shop Profile'
                  : 'Edit Shop Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Shop Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter shop name';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _gstNoController,
              decoration: InputDecoration(labelText: 'GST No(optional)'),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _ownerNameController,
              decoration: InputDecoration(labelText: 'Owner Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter owner name';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _mobileNumberController,
              decoration: InputDecoration(labelText: 'Mobile No'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter mobile no';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveShopData,
              child: Text('Save'),
            ),
            if (_isEditing)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _updateControllers();
                  });
                },
                child: Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }

}
