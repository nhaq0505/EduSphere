<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Làm quiz — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell shell--narrow">
<header class="page-heading"><div><p class="eyebrow">Đang làm bài · Lần ${attempt.attemptNumber}</p><h1><c:out value="${attempt.quiz.title}"/></h1>
<c:if test="${attempt.deadlineAt != null}"><p>Hạn nộp: <strong>${fn:replace(fn:substring(attempt.deadlineAt, 0, 16), 'T', ' ')}</strong> · Còn lại: <strong id="timer">--:--</strong></p></c:if>
</div></header>

<form id="quizForm" method="post" action="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${attemptId}/submit">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
<c:forEach var="q" items="${questions}" varStatus="st">
<article class="card" style="padding:18px;margin-bottom:14px">
<p><strong>Câu ${st.count}.</strong> <span class="small muted">(<fmt:formatNumber value="${q.score}" maxFractionDigits="1"/> điểm)</span></p>
<p style="white-space:pre-wrap"><c:out value="${q.content}"/></p>
<c:choose>
<c:when test="${q.type eq 'SINGLE_CHOICE'}">
<c:forEach var="o" items="${q.options}"><label style="display:block;margin:6px 0"><input type="radio" name="answer_${q.questionId}" value="${o.optionId}"> <c:out value="${o.content}"/></label></c:forEach>
</c:when>
<c:when test="${q.type eq 'MULTIPLE_CHOICE'}">
<p class="small muted">Chọn tất cả đáp án đúng.</p>
<c:forEach var="o" items="${q.options}"><label style="display:block;margin:6px 0"><input type="checkbox" name="answer_${q.questionId}" value="${o.optionId}"> <c:out value="${o.content}"/></label></c:forEach>
</c:when>
<c:when test="${q.type eq 'TRUE_FALSE'}">
<label style="display:block;margin:6px 0"><input type="radio" name="answer_${q.questionId}" value="true"> Đúng</label>
<label style="display:block;margin:6px 0"><input type="radio" name="answer_${q.questionId}" value="false"> Sai</label>
</c:when>
<c:when test="${q.type eq 'SHORT_ANSWER'}"><input type="text" name="answer_${q.questionId}" style="width:100%"></c:when>
<c:otherwise><textarea name="answer_${q.questionId}" rows="6" style="width:100%"></textarea></c:otherwise>
</c:choose>
</article></c:forEach>
<button class="button button--primary" type="submit" onclick="return confirm('Nộp bài? Bạn không thể sửa sau khi nộp.')">Nộp bài</button>
</form>
</main>
<c:if test="${attempt.deadlineAt != null}">
<script>
(function(){
  var end=new Date('${fn:substring(attempt.deadlineAt, 0, 19)}').getTime();
  var el=document.getElementById('timer'), form=document.getElementById('quizForm');
  function tick(){
    var left=Math.floor((end-Date.now())/1000);
    if(left<=0){el.textContent='00:00';form.submit();return;}
    el.textContent=String(Math.floor(left/60)).padStart(2,'0')+':'+String(left%60).padStart(2,'0');
    setTimeout(tick,1000);
  }
  tick();
})();
</script>
</c:if>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>
