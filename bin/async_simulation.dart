import 'dart:async';
import 'dart:math';

void main() async {
  var result =
      await waitTask("completed 1").timeout(const Duration(seconds: 10));
  print(result); // Prints "completed" after 5 seconds.

  result = await waitTask("completed 2")
      .timeout(const Duration(seconds: 1), onTimeout: () => "timeout");
  print(result); // Prints "timeout" after 1 second.

  result = await waitTask("first").timeout(const Duration(seconds: 7),
      onTimeout: () => waitTask("second"));
  print(result); // Prints "second" after 7 seconds.

  try {
    result = await waitTask("completed 3").timeout(const Duration(seconds: 2));
    print(result);
  } on TimeoutException {
    print("throws waitTask"); // Prints "throws" after 2 seconds.
  }

  var printFuture = waitPrint();
  await printFuture.timeout(const Duration(seconds: 2), onTimeout: () {
    print("timeout waitPrint"); // Prints "timeout" after 2 seconds.
  });
  await printFuture; // Prints "printed" after additional 3 seconds.

  try {
    await waitThrow("error").timeout(const Duration(seconds: 2));
  } on TimeoutException {
    print("throws waitThrow"); // Prints "throws" after 2 seconds.
  }
  // StateError is ignored

  Stopwatch watch = Stopwatch();
  watch.start();

  // delays test 
  delayedTest(); // this function is without future 
  await delayedTestFuture(); // this function is with a future and entire function is in the await state

  delayedTest1();

  delayedTest2();


  //getImageSimulatorTest - simulations of async execution 
  //https://stackoverflow.com/questions/70379083/how-do-async-await-then-really-work-in-dart

  getImageSimulatorTest();

  print("End recorded time: ${watch.elapsedMilliseconds} "); 
  
}

/// Returns [string] after five seconds.
Future<String> waitTask(String string) async {
  await Future.delayed(const Duration(seconds: 1));
  return string;
}

/// Prints "printed" after five seconds.
Future<void> waitPrint() async {
  await Future.delayed(const Duration(seconds: 5));
  print("printed");
}
/// Throws a [StateError] with [message] after five seconds.
Future<void> waitThrow(String message) async {
  await Future.delayed(const Duration(seconds: 5));
  throw Exception(message);
}

void delayedTest() async {
  print("Delayed test with awaits");
  Stopwatch watch1 = Stopwatch();
  
  watch1.start();
  
  await Future.delayed(Duration(seconds:1));
  print("Await ${watch1.elapsedMilliseconds} "); 

  await Future.delayed(Duration(seconds:1));
  print("Await ${watch1.elapsedMilliseconds} ");

  await Future.delayed(Duration(seconds:1));
  print("Await ${watch1.elapsedMilliseconds} "); 

  await Future.delayed(Duration(seconds:1));
  print("Await ${watch1.elapsedMilliseconds} ");
  //watch.stop(); // Optional: stop the stopwatch if it's no longer needed
}

//https://stackoverflow.com/questions/75175210/what-exactly-await-does-internally-in-dart
// prints 1000+
Future<void> delayedTestFuture() async {
  print("Delayed test with awaits, await entire function");
  Stopwatch watch1 = Stopwatch();
  
  watch1.start();
  
  await Future.delayed(Duration(seconds:1));
  print("Await Future ${watch1.elapsedMilliseconds} "); 

  await Future.delayed(Duration(seconds:1));
  print("Await Future ${watch1.elapsedMilliseconds} ");

  await Future.delayed(Duration(seconds:1));
  print("Await Future ${watch1.elapsedMilliseconds} "); 
  //watch.stop(); // Optional: stop the stopwatch if it's no longer needed
}

// delayed_test_1 - redesigned into nested delayes
void delayedTest1() async {
  print("Delayed test with nested delayes");
  Stopwatch watch2 = Stopwatch();
  
  watch2.start();
  
  Future.delayed(Duration(seconds:1)).then((_){
    print("Nested delay ${watch2.elapsedMilliseconds} "); 
    Future.delayed(Duration(seconds:1)).then((_){
        print("Nested delay ${watch2.elapsedMilliseconds} "); 
        Future.delayed(Duration(seconds:1)).then((_){
             print("Nested delay ${watch2.elapsedMilliseconds} "); 
        });
    });
  });
}

// prints 1000+
// The code will wait for all futures (f1, f2, f3) to complete before moving to the 
// print statement. Since Future.wait waits for all passed futures to complete, the 
// print statement will be executed after the longest future (f3) has completed, 
// which is after 3 seconds.

// What to do:
// Use descriptive and verbose variable names that clearly indicate the purpose of each local variable.
// Document the reason for waiting for all three events to finish within the function.
// Choose a function name that accurately reflects its functionality and avoid ambiguity.

// Following comments should have been there
// Insert into line 157, to describe the purpose of wait
// Wait for all delayed events to complete. This is necessary to synchronize actions that
// may depend on the completion of multiple independent asynchronous tasks.
// Right above the function 
// This function demonstrates how to use Future.wait to simultaneously await multiple delayed events.
// It measures the total time taken for the longest event to complete using a Stopwatch.
void delayedTest2() async {
  Stopwatch watch3 = Stopwatch();

  print("Unified wait for 3 futures");
  
  // a change of times in this function can influence the server 4 in the getImageSimulatorTest function 
  watch3.start();
  print("Future 1 ${watch3.elapsedMilliseconds} ");
  var f1 = Future.delayed(Duration(seconds:1));
  print("Future 2 ${watch3.elapsedMilliseconds} ");
  var f2 = Future.delayed(Duration(seconds:7));
  print("Future 3 ${watch3.elapsedMilliseconds} ");
  var f3 = Future.delayed(Duration(seconds:3));

  await Future.wait([f1, f2, f3]);

  print("Unified wait for async functions ${watch3.elapsedMilliseconds}");  
}

//Server simulation
Future<int?> getImage(String server) async {
  var rng = Random();
  
  print("Downloading from $server");
  
  // we'll add random delay to simulate network
  await Future.delayed(Duration(seconds: rng.nextInt(5)));
  
  print("$server is done");
  
  // high chance of returning null
  if (rng.nextInt(10)<7) return null;
  return 1;
}

// prints 1000+
// simulate downloading images from a server 
void getImageSimulatorTest() async {
  
  Stopwatch watch = Stopwatch();
  
  watch.start();
  
  // get the image from server 1
  var f1 = getImage("Server 1").then((data) async { 
     return data ?? await getImage("Server 1 backup");
  });
  
  var f2 = getImage("Server 2").then((data) async { 
     return data ?? await getImage("Server 2 backup");
  });

  // the lambda function Server backup gets executed here, after the get image was executed
  var f4=Future.wait([f1, f2]).then((data) async {
    if (data[0]==null || data[1]==null) {
       return [await getImage("Server 4")];
    } else {
       return data;
    }
  });
  
  var f3 = getImage("Server 3").then((data) async { 
     return data ?? await getImage("Server 3 backup");
  });

  await Future.wait([f3, f4]);

  print("elapsed ${watch.elapsedMilliseconds} ms"); 
  
}