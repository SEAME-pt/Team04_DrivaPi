use memmap2::Mmap;
use std::fs::OpenOptions;
use std::io;
use std::ptr;

#[repr(C)]
#[derive(Debug, Default, Clone, Copy)]
pub struct ObstacleOutput {
    pub sign_detected: u8,
    pub _padding: [u8; 3], // float requires 4-byte alignment
    pub confidence: f32,
}

pub struct ObstacleReader {
    mmap: Mmap,
}

impl ObstacleReader {
    pub fn new(path: &str) -> io::Result<Self> {
        let file = OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .open(path)?;

        // Ensure file is large enough
        let size = std::mem::size_of::<ObstacleOutput>() as u64;
        file.set_len(size)?;

        let mmap = unsafe { Mmap::map(&file)? };
        Ok(Self { mmap })
    }

    pub fn read(&self) -> ObstacleOutput {
        let mut output = ObstacleOutput::default();
        unsafe {
            ptr::copy_nonoverlapping(
                self.mmap.as_ptr(),
                &mut output as *mut ObstacleOutput as *mut u8,
                std::mem::size_of::<ObstacleOutput>(),
            );
        }
        output
    }
}
