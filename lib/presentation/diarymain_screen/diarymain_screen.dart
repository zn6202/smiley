import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

const Color primaryColor = Color(0xFFA7BA89);
const TextStyle selectedDateStyle = TextStyle(
    fontSize: 24.0,
    color: Color(0xFF545453),
    fontWeight: FontWeight.bold);

// 新增颜色定义
const Color calendarBackgroundColor = Color(0xFFF4F4E6);
const Color addDiaryBackgroundColor = Color(0xFFFFFFFF);

class DiaryMainScreen extends StatefulWidget {
  @override
  _DiaryMainScreenState createState() => _DiaryMainScreenState();
}

class _DiaryMainScreenState extends State<DiaryMainScreen> {
  DateTime? selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: _buildCalendar(),
              ),
              Expanded(
                flex: 1,
                child: _buildAddDiary(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      color: calendarBackgroundColor, 
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: CalendarDatePicker2(
          config: CalendarDatePicker2Config(
            selectedDayHighlightColor: primaryColor,
            selectedDayTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            weekdayLabelTextStyle: TextStyle(
              color: Color(0xFF545453),
              fontWeight: FontWeight.bold,
            ),
            dayTextStyle: TextStyle(
              color: Color(0xFF545453),
              fontWeight: FontWeight.bold,
            ),
          ),
          value: [selectedDate ?? DateTime.now()],
          onValueChanged: (value) {
            if (value.first != null) {
              setState(() {
                selectedDate = value.first;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildAddDiary() {
    return Container(
      decoration: BoxDecoration(
        color: addDiaryBackgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${selectedDate?.toIso8601String().substring(0, 10) ?? 'No date selected'}",
              style: selectedDateStyle,
            ),
            Expanded(
              child: Center(
                child: FloatingActionButton(
                  onPressed: () {},
                  child: Icon(Icons.add, size: 30),
                  backgroundColor: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*
1. _buildAddDiary()區未實現圓角 (有寫但看不出來)
2. 按鈕圖示改figma設計 (有換過路徑 但無法顯示)
3. 未連接資料庫
4. 按下按鈕後未實現
5. 上排改Wed...
6. 顯示方式改2024.05.13
*/