# frozen_string_literal: true

require "test_helper"

class ImageUploadPreviewComponentTest < ViewComponent::TestCase
  test "renders image upload preview with all core elements" do
    render_inline(ImageUploadPreviewComponent.new(
      form: mock_form,
      field_name: :avatar,
      preview_url: "/test-avatar.png",
      upload_button_text: "Upload Avatar",
      size_hint: "Recommended size: 400x400px",
      upload_button_variant: :secondary
    ))

    assert_selector "img[src='/test-avatar.png']"
    assert_selector "input[type='file'][name='user[avatar]']"
    assert_text "Upload Avatar"
    assert_text "Recommended size: 400x400px"
    assert_selector "[data-controller='upload-preview']"
  end

  test "accepts custom image styling" do
    render_inline(ImageUploadPreviewComponent.new(
      form: mock_form,
      field_name: :avatar,
      preview_url: "/test-avatar.png",
      upload_button_text: "Upload",
      size_hint: "Size hint",
      image_class: "custom-image-class"
    ))

    assert_selector "img.custom-image-class"
  end

  test "shows remove button with delete action when path provided" do
    render_inline(ImageUploadPreviewComponent.new(
      form: mock_form,
      field_name: :avatar,
      preview_url: "/test-avatar.png",
      upload_button_text: "Upload",
      size_hint: "Size hint",
      remove_path: "/user/avatar",
      remove_confirmation: "Are you sure?"
    ))

    assert_selector "a[href='/user/avatar'][data-turbo-method='delete']"
    assert_selector "a[data-turbo-confirm='Are you sure?']"
    assert_text "Remove"
  end

  test "hides remove button when no path provided" do
    render_inline(ImageUploadPreviewComponent.new(
      form: mock_form,
      field_name: :avatar,
      preview_url: "/test-avatar.png",
      upload_button_text: "Upload",
      size_hint: "Size hint"
    ))

    assert_no_text "Remove"
  end

  private

    # Stub form object that implements the minimal interface needed by the component
    class StubForm
      def file_field(field_name, options = {})
        '<input type="file" name="user[avatar]" id="user_avatar" accept="image/*" class="hidden" data-upload-preview-target="input" data-action="upload-preview#previewImage">'.html_safe
      end

      def label(field_name, options = {}, &block)
        content = block.call if block_given?
        "<label for=\"user_avatar\">#{content}</label>".html_safe
      end
    end

    def mock_form
      StubForm.new
    end
end
