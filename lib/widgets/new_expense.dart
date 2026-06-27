import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/model/expense.dart';
import 'dart:io';

class NewExpense extends StatefulWidget{
  const NewExpense({super.key,required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;
  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}
class _NewExpenseState extends State<NewExpense>{
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1,now.month,now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now, 
      firstDate: firstDate, 
      lastDate: now
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _showDialog(){
    if(Platform.isIOS){
      showCupertinoDialog(
        context: context, 
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Invalid input'),
          content: const Text('Please make sure a valid title,amount,date and category was entered.'),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(ctx);
              }, 
              child: Text('Okay'))
          ],
        ));
    } else {
      showDialog(
        context: context, 
        builder:(ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text('Please make sure a valid title,amount,date and category was entered.'),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(ctx);
              }, 
              child: Text('Okay'))
          ],
        ));
    }
  }
  void _submitExpenseData(){
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount<=0;
    if(_titleController.text.trim().isEmpty || amountIsInvalid || _selectedDate == null){
      _showDialog();
        return;
    }
    widget.onAddExpense(
      Expense(
        title: _titleController.text, 
        amount: enteredAmount, 
        date: _selectedDate!, 
        category: _selectedCategory
      )
    );
    Navigator.pop(context);
  }
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx,constraints){
      final width = constraints.maxWidth;
      return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
          child: Column(
            children: [
              if(width >=600)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                                        controller: _titleController,
                                        maxLength: 50,
                                        decoration: InputDecoration(
                      label: Text('Title')
                                        ),
                                        ),
                    ),
                  SizedBox(width: 16,),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        label: Text('amount')
                      ),
                    ),
                  ),
                ],)
              else
              TextField(
                controller: _titleController,
                maxLength: 50,
                decoration: InputDecoration(
                  label: Text('Title')
                ),
              ),
              if(width >= 600)
                Row(children: [
                  DropdownButton<Category>(
                    value: _selectedCategory,
                    items: Category.values.map(
                      (category) => DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.name.toUpperCase()),
                      ),
                    ).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                      _selectedCategory = value;
                      });
                    },
                  ),
                    Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _selectedDate == null
                                ? 'No Date selected'
                                : formatter.format(_selectedDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: _presentDatePicker,
                          icon: const Icon(Icons.calendar_month),
                        ),
                      ],
                    ),)
                ],)
              else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        label: Text('amount')
                      ),
                    ),
                  ),
                  SizedBox(width: 16,),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            _selectedDate == null
                                ? 'No date'
                                : formatter.format(_selectedDate!),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: _presentDatePicker,
                          icon: const Icon(Icons.calendar_month),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              if(width >= 600)
              Row(
                children: [
                  Spacer(),
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('cancel')
                  ),
                  ElevatedButton(
                  onPressed:_submitExpenseData,
                  child: Text('save Expense'))
                ],
              )
              else
              Row(
                children: [
                  DropdownButton(
                    value: _selectedCategory,
                    items: Category.values.map(
                      (Category) => DropdownMenuItem(
                        value: Category,
                        child: Text(Category.name.toUpperCase()))
        
                    ).toList(), 
                    onChanged: (value){
                      if(value == null){
                        return;
                      }
                      setState(() {
                        _selectedCategory = value;
                      });
                    }),
                    Spacer(),
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('cancel')
                  ),
                  ElevatedButton(
                  onPressed:_submitExpenseData,
                  child: Text('save Expense'))
                ],
              )
            ],
          ),
        ),
      ),
    );
    });
    
  }
}