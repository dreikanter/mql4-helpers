#property copyright "alex.musayev@gmail.com"
#property link      "http://alex.musayev.com"

#include <stderror.mqh>
#include <stdlib.mqh>

#import "kernel32.dll"
   void OutputDebugStringA(string msg);
#import

//
// Strings
//

// Converts double value to string w/o unnecessary zeros
string DoubleToString(double value)
{
   string result = DoubleToStr(value, 8);
   int length = StringLen(result);
   
   for(; length > 0; length--)
   {
      if(StringGetChar(result, length - 1) != '0') break;
   }
   
   if(StringGetChar(result, length - 1) == '.')
   {
      length--;
   }
   
   return(StringSubstr(result, 0, length));
}

string Join(string separator, string values[])
{
   string result;
   int size = ArraySize(values);
   
   for(int i = 0; i < size; i++)
   {
      result = StringConcatenate(result, values[i]);
      
      if(i < size - 1)
      {
         result = StringConcatenate(result, separator);
      }
   }

   return(result);
}

// Converts string to upper case (for english text only).
string StringUpper(string str)
{
   string s = str;
   int lenght = StringLen(str) - 1;
   int symbol;
   
   while(lenght >= 0)
   {
      symbol = StringGetChar(s, lenght);
      
      if((symbol > 96 && symbol < 123) || (symbol > 223 && symbol < 256))
      {
         s = StringSetChar(s, lenght, symbol - 32);
      }
      else if(symbol > -33 && symbol < 0)
      {
         s = StringSetChar(s, lenght, symbol + 224);
      }
      
      lenght--;
   }

   return(s);
}

// Converts string to lower case (for english text only).
string StringLower(string str)
{
   string s = str;
   int lenght = StringLen(str) - 1;
   int symbol;
   
   while(lenght >= 0)
   {
      symbol = StringGetChar(s, lenght);
      
      if((symbol > 64 && symbol < 91) || (symbol > 191 && symbol < 224))
      {
         s = StringSetChar(s, lenght, symbol + 32);
      }
      else if(symbol > -65 && symbol < -32)
      {
         s = StringSetChar(s, lenght, symbol + 288);
      }
      
      lenght--;
   }
   
   return(s);
}

//
// Date and Time
//

// Converts HH:MM or HH:MM:SS string to datetime value.
// Returns true when convertion is succeeded.
bool StringToTime(string value, datetime& result)
{
   result = StrToTime(value);
   return((TimeToStr(result, TIME_MINUTES) == value) || 
          (TimeToStr(result, TIME_SECONDS) == value));
}

// Compares two datetimes ignoring the date part
bool TimeEquals(datetime a, datetime b)
{
   return(TimeHour(a) == TimeHour(b) &&
          TimeMinute(a) == TimeMinute(b) &&
          TimeSeconds(a) == TimeSeconds(b));
}

//
// Logging
//

bool _DebugViewEnabled = false;

void EnableDebugView()
{
   _DebugViewEnabled = true;
}

void DisableDebugView()
{
   _DebugViewEnabled = false;
}

void SetDebugView(bool enabled)
{
   _DebugViewEnabled = enabled;
}

bool GetDebugView()
{
   return(_DebugViewEnabled);
}

void Log(string message, string symbol = "")
{
   _Log("", symbol, message);
}

void LogFatal(string message, string symbol = "")
{
   _Log("Fatal", symbol, message);
}

void LogError(string message, string symbol = "")
{
   _Log("Error", symbol, message);
}

void LogWarn(string message, string symbol = "")
{
   _Log("Warn", symbol, message);
}

void LogDebug(string message, string symbol = "")
{
   _Log("Debug", symbol, message);
}

void LogInfo(string message, string symbol = "")
{
   _Log("Info", symbol, message);
}

void LogLastError(string symbol = "")
{
   int error = GetLastError();
   LogError(ErrorDescription(error) + "(code " + error + ")");
}

void _Log(string status, string symbol, string message)
{
   string msg = message;
   if(status == "") msg = message; else msg = status + ": " + message; 
   Print(msg);
   
   if(_DebugViewEnabled)
   {
      string prefix = "";
      if(symbol != "") prefix = GetExpertName(symbol) + " ";
      OutputDebugStringA(prefix + msg);
   }
}

//
// Misc
//

color _Colors[] = { Maroon, Indigo, MidnightBlue, DarkBlue, DarkOliveGreen, SaddleBrown, ForestGreen, OliveDrab,
                   SeaGreen, DarkGoldenrod, DarkSlateBlue, Sienna, MediumBlue, Brown, DarkTurquoise, DimGray,
                   LightSeaGreen, DarkViolet, FireBrick, MediumVioletRed, MediumSeaGreen, Chocolate, Crimson, SteelBlue,
                   Goldenrod, MediumSpringGreen, LawnGreen, CadetBlue, DarkOrchid, YellowGreen, LimeGreen, OrangeRed,
                   DarkOrange, Orange, Gold, Yellow, Chartreuse, Lime, SpringGreen, Aqua };

int _LastColor = 0;

color GetNextColor()
{
   color result = _Colors[_LastColor];
   _LastColor = (_LastColor + 1) % ArraySize(_Colors);
   return(result);
}

string GetExpertName(string symbol = "")
{
   string result = WindowExpertName();
   
   if(StringLen(symbol) > 0)
   {
      result = result + " [" + symbol + "]";
   }
   
   return(result);
}

string GetOperationName(int operation)
{
   switch(operation)
   {
      case OP_BUY:
         return("Buy");

      case OP_SELL:
         return("Sell");

      case OP_BUYLIMIT:
         return("Buy limit pending");

      case OP_SELLLIMIT:
         return("Sell limit pending");

      case OP_BUYSTOP:
         return("Buy stop pending");

      case OP_SELLSTOP:
         return("Sell stop pending");

      default:
         return("Operation #" + operation);
   }
}

