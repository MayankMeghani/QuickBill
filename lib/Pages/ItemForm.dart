import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:quickbill/Models/Item.dart';
import 'package:quickbill/Services/ItemServices.dart';
import '../Providers/ShopProvider.dart';

class ItemForm extends StatefulWidget {
  @override
  _ItemFormState createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController priceController;
  File? _image =null;
  String? _imageUrl;
  final picker = ImagePicker();
  bool _isUploading = false;
  bool _isExistingItem = false;
  final _formKey = GlobalKey<FormState>();
  ItemServices itemServices = new ItemServices();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    quantityController = TextEditingController();
    priceController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _isExistingItem = true;
      nameController.text = args['name'] ?? '';
      quantityController.text = (args['quantity'] ?? 0).toString();
      priceController.text = (args['price'] ?? 0.0).toString();
      _imageUrl = args['imageUrl'];
      setState(() {});
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _imageUrl = null;
      }
    });
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a Photo'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('items');
      Reference referenceImageToUpload = referenceDirImages.child(fileName);

      await referenceImageToUpload.putFile(imageFile);
      String imageUrl = await referenceImageToUpload.getDownloadURL();

      return imageUrl;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<void> saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    String? imageUrl = _imageUrl;

    if (_image != null) {
      imageUrl = await uploadImageToFirebase(_image!);
    }

    if (imageUrl == null) {
      imageUrl = '';
    }

    final shopId = Provider.of<ShopProvider>(context, listen: false).shopData?['userId'];
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? itemId = args?['id'];

    try {
      final itemData = Item(
        name: nameController.text,
        imageUrl: imageUrl,
        quantity: int.parse(quantityController.text),
        price: double.parse(priceController.text),
        shopId: shopId,
      );

      if (_isExistingItem && itemId != null) {
        await itemServices.updateItem(itemId,itemData);
      } else {
        await itemServices.AddShopItem(itemData);
      }

      setState(() {
        _isUploading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving item: $e')),
      );
    }
  }


  Widget _buildImagePreview() {
    if (_image != null) {
      return Image.file(_image!, height: 200);
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return Image.network(
        _imageUrl!,
        height: 200,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Text('Error loading image');
        },
      );
    } else {
      return Text('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isExistingItem ? 'Modify Item' : 'Add Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity < 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showImageSourceActionSheet(context),
                child: Text('Select Image'),
              ),
              SizedBox(height: 20),
              _buildImagePreview(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : saveItem,
                child: _isUploading
                    ? CircularProgressIndicator()
                    : Text(_isExistingItem ? 'Save Changes' : 'Add Item'),
              ),
            ],
          ),

        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }
}