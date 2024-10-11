package com.foomyfood.foomyfood.service;

import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.Bucket;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
public class GoogleCloudStorageService {

    private final Storage storage = StorageOptions.getDefaultInstance().getService();

    @Value("${gcs.bucket-name}")
    private String bucketName;

    // 上传文件到Google Cloud Storage
    public String uploadFile(MultipartFile file) throws IOException {
//        // 生成唯一文件名
//        String fileName = UUID.randomUUID().toString() + "-" + file.getOriginalFilename();
//        Bucket bucket = storage.get(bucketName);
//
//        // 上传文件到Google Cloud Storage
//        Blob blob = bucket.create(fileName, file.getBytes(), file.getContentType());
//
//        // 返回文件的URL
//        return String.format("https://storage.googleapis.com/%s/%s", bucketName, fileName);
        // 生成唯一文件名
        String fileName = UUID.randomUUID().toString() + "-" + file.getOriginalFilename();
        try {
            Bucket bucket = storage.get(bucketName);
            Blob blob = bucket.create(fileName, file.getBytes(), file.getContentType());
            return String.format("https://storage.googleapis.com/%s/%s", bucketName, fileName);
        } catch (Exception e) {
            // 打印更多错误信息到日志
            System.err.println("Failed to upload file to Google Cloud: " + e.getMessage());
            throw new IOException("Failed to upload file", e);
        }
    }

    // 删除Google Cloud Storage中的文件
    public void deleteFile(String fileUrl) {
        // 从文件URL中提取文件名
        String fileName = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);

        // 获取BlobId，并删除文件
        BlobId blobId = BlobId.of(bucketName, fileName);
        boolean deleted = storage.delete(blobId);

        if (deleted) {
            System.out.println("File " + fileName + " was deleted successfully.");
        } else {
            System.out.println("File " + fileName + " not found.");
        }
    }
}
