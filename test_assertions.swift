#!/usr/bin/env swift

import Foundation
import IOKit.pwr_mgt

print("Testing IOPMAssertion functionality...")

var assertionID: IOPMAssertionID = 0
var displayAssertionID: IOPMAssertionID = 0

print("Creating assertions...")
let systemResult = IOPMAssertionCreateWithName(
    kIOPMAssertionTypeNoIdleSleep as CFString,
    IOPMAssertionLevel(kIOPMAssertionLevelOn),
    "Test Mira Sleep Prevention" as CFString,
    &assertionID
)

let displayResult = IOPMAssertionCreateWithName(
    kIOPMAssertionTypeNoDisplaySleep as CFString,
    IOPMAssertionLevel(kIOPMAssertionLevelOn),
    "Test Mira Display Sleep Prevention" as CFString,
    &displayAssertionID
)

print("System assertion result: \(systemResult == kIOReturnSuccess ? "SUCCESS" : "FAILED") (ID: \(assertionID))")
print("Display assertion result: \(displayResult == kIOReturnSuccess ? "SUCCESS" : "FAILED") (ID: \(displayAssertionID))")

print("\nSleeping for 5 seconds to test assertions...")
sleep(5)

print("Releasing assertions...")
if assertionID != 0 {
    IOPMAssertionRelease(assertionID)
    print("System assertion released")
}

if displayAssertionID != 0 {
    IOPMAssertionRelease(displayAssertionID)
    print("Display assertion released")
}

print("Test complete.")