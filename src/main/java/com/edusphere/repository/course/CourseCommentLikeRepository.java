package com.edusphere.repository.course;

import com.edusphere.entity.course.CourseCommentLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface CourseCommentLikeRepository extends JpaRepository<CourseCommentLike, Integer> {

    Optional<CourseCommentLike> findByComment_CommentIdAndUser_UserId(Integer commentId, Integer userId);

    boolean existsByComment_CommentIdAndUser_UserId(Integer commentId, Integer userId);

    List<CourseCommentLike> findByComment_CommentIdInAndUser_UserId(Collection<Integer> commentIds, Integer userId);

    @Query("SELECT l.comment.commentId FROM CourseCommentLike l WHERE l.user.userId = :userId AND l.comment.commentId IN :commentIds")
    List<Integer> findLikedCommentIdsByUser(@Param("userId") Integer userId, @Param("commentIds") Collection<Integer> commentIds);

    long countByComment_CommentId(Integer commentId);
}
