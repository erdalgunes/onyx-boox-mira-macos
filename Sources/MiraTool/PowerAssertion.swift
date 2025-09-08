import Foundation
import IOKit.pwr_mgt

class PowerAssertion {
    private var assertionID: IOPMAssertionID = 0
    private var displayAssertionID: IOPMAssertionID = 0
    
    var isActive: Bool {
        return assertionID != 0 || displayAssertionID != 0
    }
    
    func createAssertion() {
        releaseAssertion()
        
        let systemAssertionResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoIdleSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Mira E-ink Display: Preventing system idle sleep" as CFString,
            &assertionID
        )
        
        let displayAssertionResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Mira E-ink Display: Preventing display sleep" as CFString,
            &displayAssertionID
        )
        
        if systemAssertionResult != kIOReturnSuccess {
            print("Warning: Failed to create system sleep assertion")
        }
        
        if displayAssertionResult != kIOReturnSuccess {
            print("Warning: Failed to create display sleep assertion")
        }
    }
    
    func releaseAssertion() {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
        
        if displayAssertionID != 0 {
            IOPMAssertionRelease(displayAssertionID)
            displayAssertionID = 0
        }
    }
    
    deinit {
        releaseAssertion()
    }
}