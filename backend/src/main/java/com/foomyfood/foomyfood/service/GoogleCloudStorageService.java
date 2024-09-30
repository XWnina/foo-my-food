package com.foomyfood.foomyfood.service;


import com.google.cloud.storage.Blob;
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

    public String uploadFile(MultipartFile file) throws IOException {
        // 生成唯一文件名
        String fileName = UUID.randomUUID().toString() + "-" + file.getOriginalFilename();
        Bucket bucket = storage.get(bucketName);

        // 上传文件到Google Cloud Storage，不设置对象级别的ACL
        Blob blob = bucket.create(fileName, file.getBytes(), file.getContentType());

        // 返回文件的URL（根据存储桶的访问权限配置，可能是公开的，也可能是私有的）
        return String.format("https://storage.googleapis.com/%s/%s", bucketName, fileName);
    }
}
