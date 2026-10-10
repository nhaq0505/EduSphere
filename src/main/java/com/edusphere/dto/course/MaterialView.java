package com.edusphere.dto.course;

public record MaterialView(
        Integer materialId,
        String title,
        String type,
        String fileUrl,
        String originalFileName,
        Long sizeBytes
) {
    public Integer getMaterialId() { return materialId(); }
    public String getTitle() { return title(); }
    public String getType() { return type(); }
    public String getFileUrl() { return fileUrl(); }
    public String getOriginalFileName() { return originalFileName(); }
    public Long getSizeBytes() { return sizeBytes(); }
}
