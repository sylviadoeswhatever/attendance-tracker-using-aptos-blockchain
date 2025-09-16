module MyModule::ClassRSVP {
    use aptos_framework::signer;
    use std::vector;
    use aptos_framework::timestamp;

    /// Struct representing a live class with RSVP tracking
    struct LiveClass has store, key {
        class_name: vector<u8>,        // Name/title of the class
        class_time: u64,               // Scheduled class time (timestamp)
        attendees: vector<address>,    // List of students who RSVP'd
        total_rsvps: u64,              // Total number of RSVPs
        max_capacity: u64,             // Maximum class capacity
    }

    /// Function to create a new live class session
    public fun create_class(teacher: &signer, class_name: vector<u8>, class_time: u64, max_capacity: u64) {
        let live_class = LiveClass {
            class_name,
            class_time,
            attendees: vector::empty<address>(),
            total_rsvps: 0,
            max_capacity,
        };
        move_to(teacher, live_class);
    }

    /// Function for students to RSVP for a class
    public fun rsvp_for_class(student: &signer, teacher_address: address) acquires LiveClass {
        let student_addr = signer::address_of(student);
        let class = borrow_global_mut<LiveClass>(teacher_address);
        
        // Check if class is at capacity
        if (class.total_rsvps >= class.max_capacity) {
            return // Class is full, exit silently
        };

        // Check if student has already RSVP'd
        let i = 0;
        let len = vector::length(&class.attendees);
        while (i < len) {
            if (*vector::borrow(&class.attendees, i) == student_addr) {
                return // Already RSVP'd, exit silently
            };
            i = i + 1;
        };

        // Add student to attendees list
        vector::push_back(&mut class.attendees, student_addr);
        class.total_rsvps = class.total_rsvps + 1;
    }
}
    