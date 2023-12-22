class Hatalar {
  static String goster(String hataKodu) {
    switch (hataKodu) {
      case 'email-already-in-use':
        return 'Bu mail adresi zaten kullanımda, lütfen farklı bir mail kulllanınız';

      case 'user-not-found':
        return 'Bu kullanıcı sistemde bulunmamaktadır. Lütfen önce kullanıcı oluşturunuz';
      default:
        return 'Bir hata oluştu';
    }
  }
}
