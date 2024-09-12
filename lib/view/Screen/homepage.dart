import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  final TextEditingController cateController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  int? editingIndex;



  final String baseUrl = "https://fakestoreapi.com/products";

  Future<void> fetchPosts() async {
    try {
      var response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          products = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("Failed to load posts: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }


  Future<void> createPost(String description, String category) async {
    try {
      var response = await http.post(
        Uri.parse(baseUrl + "/create"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'description': description,
          'category': category,
        }),
      );
      if (response.statusCode == 201) {
        fetchPosts();
      } else {
        print("Failed to create post: ${response.statusCode}");
      }
    } catch (e) {
      print("Error creating post: $e");
    }
  }

  Future<void> deletePost(String title) async {
    try {
      var response = await http.delete(
        Uri.parse('$baseUrl/$title'),
      );
      if (response.statusCode == 200) {
        fetchPosts();
      } else {
        print("Failed to delete post: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting post: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUD Operations"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            textField("Enter Post Title", "Title", titleController),
            const SizedBox(height: 20),
            textField("Enter Post Description", "Description", desController),
            const SizedBox(height: 20),
            textField("Enter Post Category", "Category", cateController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    desController.text.isNotEmpty) {
                  if (editingIndex != null) {
                    deletePost(products[editingIndex!]['id']);
                    createPost(desController.text, titleController.text);
                  } else {
                    createPost(cateController.text, titleController.text);
                  }

                  desController.clear();
                  titleController.clear();
                  cateController.clear();
                  editingIndex = null;
                }
              },
              child: Text(editingIndex == null ? "Submit" : "Update"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var post = products[index];
                  return ListTile(
                    title: Text(post['title'] ?? ''),
                    subtitle: Text(post['description'] ?? ''),
                    leading: Text(post['category'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              titleController.text = post['title'] ?? '';
                              desController.text = post['description'] ?? '';
                              cateController.text = post['category'] ?? '';
                              editingIndex = index;
                            });
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            deletePost(post['title']);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textField(String hint, String label, TextEditingController controller) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      controller: controller,
    );
  }
}
