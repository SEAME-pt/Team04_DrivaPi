use memmap2::Mmap;
use std::fs::OpenOptions;
use std::io;
use std::ptr;

#[repr(C)]
#[derive(Debug, Default, Clone, Copy)]
pub struct PerceptionOutput {
    pub closest_front_point: f32,
    pub heading_error: f32,
    pub confidence: f32,
    pub valid: u8,
    pub _padding: [u8; 3], // Match Python's fffBxxxQ (3 bytes padding)
    pub timestamp: u64,
}

pub struct PerceptionReader {
    mmap: Mmap,
}

impl PerceptionReader {
    pub fn new(path: &str) -> io::Result<Self> {
        let file = OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .open(path)?;
        
        // Ensure file is large enough
        let size = std::mem::size_of::<PerceptionOutput>() as u64;
        file.set_len(size)?;

        let mmap = unsafe { Mmap::map(&file)? };
        Ok(Self { mmap })
    }

    pub fn read(&self) -> PerceptionOutput {
        let mut output = PerceptionOutput::default();
        unsafe {
            ptr::copy_nonoverlapping(
                self.mmap.as_ptr(),
                &mut output as *mut PerceptionOutput as *mut u8,
                std::mem::size_of::<PerceptionOutput>(),
            );
        }
        output
    }
}
