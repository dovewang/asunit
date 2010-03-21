package asunit4.runners {

	import asunit.framework.ITestFailure;
	import asunit.framework.TestCase;
	import asunit4.framework.Result;
	import asunit4.framework.TestFailure;
	import asunit4.support.MultiMethod;
    import asunit4.support.InjectionVerification;
    
	import flash.events.Event;

	public class TestRunnerTest extends TestCase {

		private var runner:TestRunner;
		private var runnerResult:Result;
		private var test:Class;

		public function TestRunnerTest(testMethod:String = null) {
			super(testMethod);
		}

		protected override function setUp():void {
            super.setUp();
			runner = new TestRunner();
			runnerResult = new Result();
			// Yes, statics are ugly, but we're testing that static methods are called, e.g. [BeforeClass].
			MultiMethod.methodsCalled = [];
			test = MultiMethod;
		}

		protected override function tearDown():void {
            super.tearDown();
			runner = null;
			MultiMethod.methodsCalled = null;
		}

		public function testInstantiated():void {
			assertTrue("TestRunner instantiated", runner is TestRunner);
		}
		
		public function testTestDoesNotExtendTestCase():void {
			assertFalse(test is TestCase);
		}

		public function testRunMethodsAlphabetically():void {
			runner.addEventListener(Event.COMPLETE, addAsync(checkMethodsCalledAfterRunningTestInstance, 500));
			runner.run(test, runnerResult);
		}
		
		private function checkMethodsCalledAfterRunningTestInstance(e:Event):void {
			var i:uint = 0;
			
			assertSame(MultiMethod.runBeforeClass1, 		MultiMethod.methodsCalled[i++]);
			assertSame(MultiMethod.runBeforeClass2, 		MultiMethod.methodsCalled[i++]);
			
			assertSame(runner.currentTest.runBefore1, 						MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runBefore2, 						MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.fail_assertEquals,				MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runAfter1, 						MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runAfter2, 						MultiMethod.methodsCalled[i++]);

			assertSame(runner.currentTest.runBefore1, 						MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runBefore2, 						MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.numChildren_is_0_by_default,		MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runAfter1, 						MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runAfter2, 						MultiMethod.methodsCalled[i++]);
			
			assertSame(runner.currentTest.runBefore1, 						MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runBefore2, 						MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.stage_is_null_by_default, 		MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runAfter1, 						MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runAfter2, 						MultiMethod.methodsCalled[i++]);
			
			assertSame(MultiMethod.runAfterClass1, 			MultiMethod.methodsCalled[i++]);
			assertSame(MultiMethod.runAfterClass2, 			MultiMethod.methodsCalled[i++]);
			
			assertEquals('checked all methodsCalled', MultiMethod.methodsCalled.length, i);
		}

		public function testRunTriggersResultEvent():void {
			runner.addEventListener(Event.COMPLETE, addAsync(checkResultWasNotSuccessful, 500));
			runner.run(test, runnerResult);
		}
		
		private function checkResultWasNotSuccessful(e:Event):void {
            assertTrue(runnerResult.failureEncountered);
			assertFalse(runnerResult.wasSuccessful);
			
			var failures:Array = runnerResult.failures;
			assertEquals('one failure in testResult', 1, failures.length);
			
			var failure0:ITestFailure = failures[0] as TestFailure;
			assertTrue("failedTest is instance of test class", failure0.failedTest is test);
		}

		public function testRunMethodByNameExecutesExpectedSequence():void {
			var delegate:Function = addAsync(checkMethodsCalledAfterRunningTestMethodByName, 500);
			runner.addEventListener(Event.COMPLETE, delegate);
			
			var testMethodName:String = 'stage_is_null_by_default';
			runner.runMethodByName(test, runnerResult, null, testMethodName);
		}
		
		private function checkMethodsCalledAfterRunningTestMethodByName(e:Event):void {
			var i:uint = 0;
			
			assertSame(MultiMethod.runBeforeClass1, 		        MultiMethod.methodsCalled[i++]);
			assertSame(MultiMethod.runBeforeClass2, 		        MultiMethod.methodsCalled[i++]);
			
			assertSame(runner.currentTest.runBefore1, 				MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runBefore2, 				MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.stage_is_null_by_default,	MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runAfter1, 				MultiMethod.methodsCalled[i++]);
			assertSame(runner.currentTest.runAfter2, 				MultiMethod.methodsCalled[i++]);
			
			assertSame(MultiMethod.runAfterClass1, 			        MultiMethod.methodsCalled[i++]);
			assertSame(MultiMethod.runAfterClass2, 			        MultiMethod.methodsCalled[i++]);
			
			assertEquals('checked all methodsCalled',               MultiMethod.methodsCalled.length, i);
		}

        // This an interesting hack in that an AsUnit 4 Test Case is being instantiated
        // and executed, but in this environment, we're simply checking to see if it passed,
        // and outputing any failures to the message...
        public function testInjectTypes():void {
            runner.run(InjectionVerification, runnerResult, getContext());
            assertFalse("Should not have encountered failures: " + runnerResult.failures.join("\n\n"), runnerResult.failureEncountered);
        }
	}
}
